import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/widgets/media/media_cache.dart';

class PdfViewScreen extends StatefulWidget {
  final String filePath;
  final String? fileName;
  final bool isNetworkFile;

  const PdfViewScreen({
    super.key,
    required this.filePath,
    this.fileName,
    this.isNetworkFile = false,
  });

  @override
  State<PdfViewScreen> createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  late PDFViewController _pdfController;
  String? _localFilePath;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePdf();
  }

  Future<void> _initializePdf() async {
    try {
      if (_isNetworkUrl(widget.filePath)) {
        log('Downloading network PDF: ${widget.filePath}');
        _localFilePath = await _downloadPdf(widget.filePath);
      } else {
        log('Using local PDF: ${widget.filePath}');
        _localFilePath = widget.filePath;
      }

      if (_localFilePath != null && await File(_localFilePath!).exists()) {
        log('PDF file ready: $_localFilePath');
        setState(() {
          _isLoading = false;
        });
      } else {
        _setError('PDF file not found at: $_localFilePath');
      }
    } catch (e) {
      log('PDF initialization error: $e');
      _setError('Failed to load PDF: $e');
    }
  }

  bool _isNetworkUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  Future<String?> _downloadPdf(String url) async {
    try {
      log('Starting PDF download from: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getTemporaryDirectory();
        final fileName =
            widget.fileName ??
            'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);
        log('PDF downloaded successfully to: ${file.path}');
        return file.path;
      } else {
        log('PDF download failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error downloading PDF: $e');
      return null;
    }
  }

  void _setError(String message) {
    log('PDF Error: $message');
    setState(() {
      _isLoading = false;
      _hasError = true;
      _errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          context.pop();
        },
        icon: Icon(Icons.arrow_back_ios),
      ),
      foregroundColor: Colors.white,
      title: Text(
        widget.fileName ?? 'PDF Document',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      actions: [
        if (!_isLoading && !_hasError) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            margin: EdgeInsets.only(right: 8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              '${_currentPage + 1} / $_totalPages',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(onPressed: _sharePdf, icon: const Icon(Icons.share)),
          IconButton(
            onPressed: _downloadToDevice,
            icon: const Icon(Icons.download),
          ),
          // More options
          // PopupMenuButton<String>(
          //   onSelected: _handleMenuAction,
          //   itemBuilder: (context) => [
          //     const PopupMenuItem(
          //       value: 'open_external',
          //       child: Row(
          //         children: [
          //           Icon(Icons.open_in_new),
          //           SizedBox(width: 8),
          //           Text('Open in External App'),
          //         ],
          //       ),
          //     ),
          //     const PopupMenuItem(
          //       value: 'zoom_fit',
          //       child: Row(
          //         children: [
          //           Icon(Icons.fit_screen),
          //           SizedBox(width: 8),
          //           Text('Fit to Screen'),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_hasError) {
      return _buildErrorWidget();
    }

    return Stack(
      children: [
        PDFView(
          filePath: _localFilePath!,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          pageSnap: true,
          defaultPage: 0,
          fitPolicy: FitPolicy.WIDTH,
          preventLinkNavigation: false,
          onRender: (pages) {
            setState(() {
              _totalPages = pages ?? 0;
            });
            log('PDF rendered with $_totalPages pages');
          },
          onViewCreated: (controller) {
            _pdfController = controller;
            log('PDF view created successfully');
          },
          onPageChanged: (page, total) {
            setState(() {
              _currentPage = page ?? 0;
              _totalPages = total ?? 0;
            });
          },
          onError: (error) {
            _setError('PDF rendering error: $error');
          },
          onPageError: (page, error) {
            log('PDF page error on page $page: $error');
          },
        ),
        _buildNavigationControls(),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 16.h),
          Text(
            _isNetworkUrl(widget.filePath)
                ? 'Downloading PDF...'
                : 'Loading PDF...',
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            widget.fileName ?? 'Document',
            style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            SizedBox(height: 16.h),
            Text(
              'Failed to Load PDF',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(width: 16.w),
                ElevatedButton.icon(
                  onPressed: _retryLoading,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationControls() {
    if (_totalPages <= 1) return const SizedBox.shrink();

    return Positioned(
      bottom: 20.h,
      left: 20.w,
      right: 20.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(25.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavButton(
              icon: Icons.first_page,
              onPressed: _currentPage > 0 ? () => _goToPage(0) : null,
            ),
            _buildNavButton(
              icon: Icons.chevron_left,
              onPressed: _currentPage > 0 ? _previousPage : null,
            ),
            Expanded(
              child: Slider(
                value: _currentPage.toDouble(),
                min: 0,
                max: (_totalPages - 1).toDouble(),
                divisions: _totalPages > 1 ? _totalPages - 1 : 1,
                activeColor: Colors.blue[400],
                inactiveColor: Colors.grey[600],
                onChanged: (value) {
                  _goToPage(value.round());
                },
              ),
            ),
            _buildNavButton(
              icon: Icons.chevron_right,
              onPressed: _currentPage < _totalPages - 1 ? _nextPage : null,
            ),
            _buildNavButton(
              icon: Icons.last_page,
              onPressed: _currentPage < _totalPages - 1
                  ? () => _goToPage(_totalPages - 1)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: onPressed != null ? Colors.white : Colors.grey[600],
        size: 20,
      ),
      padding: EdgeInsets.all(8.w),
      constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
    );
  }

  void _goToPage(int page) {
    _pdfController.setPage(page);
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pdfController.setPage(_currentPage - 1);
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pdfController.setPage(_currentPage + 1);
    }
  }

  void _retryLoading() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    _initializePdf();
  }

  Future<void> _sharePdf() async {
    if (_localFilePath != null) {
      try {
        await Share.shareXFiles([XFile(_localFilePath!)], text: 'PDF Document');
      } catch (e) {
        _showSnackBar('Failed to share PDF: $e');
      }
    } else {
      _showSnackBar('No PDF file available to share.');
    }
  }

  Future<void> _downloadToDevice() async {
    try {
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (await downloadsDir.exists()) {
        final fileName =
            widget.fileName ??
            'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final newFile = File('${downloadsDir.path}/$fileName');
        await File(_localFilePath!).copy(newFile.path);
        _showSnackBar('PDF saved to Downloads/$fileName');
      } else {
        _showSnackBar('Downloads folder not accessible');
      }
    } catch (e) {
      _showSnackBar('Failed to download PDF: $e');
    }
  }

  // Future<void> _handleMenuAction(String action) async {
  //   switch (action) {
  //     case 'open_external':
  //       await _openInExternalApp();
  //       break;
  //     case 'zoom_fit':
  //       // Implement zoom to fit functionality
  //       _showSnackBar('Zoom to fit - implement as needed');
  //       break;
  //   }
  // }

  // Future<void> _openInExternalApp() async {
  //   if (_localFilePath != null) {
  //     final uri = Uri.file(_localFilePath!);
  //     if (await canLaunchUrl(uri)) {
  //       await launchUrl(uri);
  //     } else {
  //       _showSnackBar('No app available to open PDF');
  //     }
  //   }
  // }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.grey[800],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// FIXED: Updated Document Preview Widget with better file type detection
class InstantDocumentPreview extends StatelessWidget {
  final String fileUrl;
  final String mediaId;
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const InstantDocumentPreview({
    super.key,
    required this.fileUrl,
    required this.mediaId,
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: maxWidth ?? (isInChatBubble ? 150.w : 200.w),
      height: maxHeight ?? (isInChatBubble ? 60.h : 80.h),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: InkWell(
        onTap: () => _handleDocumentTap(context),
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Row(
            children: [
              Icon(
                Icons.picture_as_pdf,
                color: Colors.red[700],
                size: isInChatBubble ? 24.sp : 32,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'PDF Document',
                      style: TextStyle(
                        fontSize: isInChatBubble ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isInChatBubble) ...[
                      SizedBox(height: 2.h),
                      Text(
                        'Tap to open',
                        style: TextStyle(fontSize: 10, color: Colors.red[500]),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.open_in_new, size: 16, color: Colors.red[600]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDocumentTap(BuildContext context) async {
    try {
      String? filePath = MediaCache.getFilePath(mediaId);
      String? fileName;
      bool isNetworkFile = false;

      log('Document tap - Original URL: $fileUrl');
      log('Cached file path: $filePath');

      isNetworkFile = false;

      log('Opening PDF viewer with: $filePath (isNetwork: $isNetworkFile)');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewScreen(
            filePath: filePath ?? '',
            fileName: fileName,
            isNetworkFile: isNetworkFile,
          ),
        ),
      );
    } catch (e) {
      log('Document open error: $e');
      _showSnackBar(context, 'Failed to open document: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
