import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FixedSizeHtmlWidget extends StatefulWidget {
  final String htmlContent;
  final double width;
  final double height;
  final bool isSentMessage;
  final Function(Map<String, dynamic>)? onFormSubmit;
  final Function(String)? onLinkTap;
  final Function(String)? onError;

  const FixedSizeHtmlWidget({
    super.key,
    required this.htmlContent,
    this.width = 350,
    this.height = 400,
    this.isSentMessage = false,
    this.onFormSubmit,
    this.onLinkTap,
    this.onError,
  });

  @override
  State<FixedSizeHtmlWidget> createState() => _FixedSizeHtmlWidgetState();
}

class _FixedSizeHtmlWidgetState extends State<FixedSizeHtmlWidget> {
  late final WebViewController controller;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  String htmlType = 'unknown';

  @override
  void initState() {
    super.initState();
    htmlType = _detectHtmlType(widget.htmlContent);
    _initializeController();
  }

  String _detectHtmlType(String html) {
    final content = html.toLowerCase();

    if (content.contains('patient') && content.contains('status')) {
      return 'patient_card';
    } else if (content.contains('form') ||
        content.contains('<input') ||
        content.contains('<select')) {
      return 'form';
    } else if (content.contains('table') ||
        content.contains('<th') ||
        content.contains('<td')) {
      return 'table';
    } else if (content.contains('chart') ||
        content.contains('canvas') ||
        content.contains('svg')) {
      return 'chart';
    } else if (content.contains('card') || content.contains('profile')) {
      return 'card';
    } else if (content.contains('<img') || content.contains('image')) {
      return 'media';
    } else if (content.contains('<h1') ||
        content.contains('<h2') ||
        content.contains('<p')) {
      return 'document';
    } else if (content.contains('<!doctype') || content.contains('<html')) {
      return 'full_page';
    }

    return 'fragment';
  }

  void _initializeController() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _handleJavaScriptMessage(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                isLoading = true;
                hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
            _setupFixedSizeHtml();
          },
          onWebResourceError: (WebResourceError error) {
            log('WebView Error: ${error.description}');
            if (mounted) {
              setState(() {
                isLoading = false;
                hasError = true;
                errorMessage = error.description;
              });
            }
            widget.onError?.call(error.description);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('http') ||
                request.url.startsWith('https')) {
              if (request.url.contains('cdn.') ||
                  request.url.contains('googleapis.') ||
                  request.url.contains('bootstrap') ||
                  request.url.contains('tailwind')) {
                log('Blocked CDN request: ${request.url}');
                return NavigationDecision.prevent;
              } else {
                widget.onLinkTap?.call(request.url);
                return NavigationDecision.prevent;
              }
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    _loadProcessedHtml();
  }

  void _loadProcessedHtml() {
    try {
      String processedHtml = _processFixedSizeHtml(widget.htmlContent);
      log('Loading fixed-size HTML: $htmlType (${processedHtml.length} chars)');
      controller.loadHtmlString(processedHtml);
    } catch (e) {
      log('Error processing HTML: $e');
      setState(() {
        hasError = true;
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  String _processFixedSizeHtml(String htmlContent) {
    String content = htmlContent.trim().replaceAll('\r\n', '\n');
    content = _removeExternalResources(content);
    return _wrapInFixedContainer(content);
  }

  String _removeExternalResources(String html) {
    return html
        .replaceAll(
          RegExp(r'<script[^>]*cdn\.tailwindcss\.com[^>]*></script>'),
          '',
        )
        .replaceAll(RegExp(r'<script[^>]*googleapis\.com[^>]*></script>'), '')
        .replaceAll(RegExp(r'<script[^>]*bootstrap[^>]*></script>'), '')
        .replaceAll(RegExp(r'<script[^>]*jquery[^>]*></script>'), '')
        .replaceAll(RegExp(r'<link[^>]*cdn\.[^>]*>'), '')
        .replaceAll(RegExp(r'<link[^>]*googleapis[^>]*>'), '')
        .replaceAll(RegExp(r'<link[^>]*bootstrap[^>]*>'), '');
  }

  String _wrapInFixedContainer(String content) {
    final containerWidth = widget.width - 24;
    final containerHeight = widget.height - 24;

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Fixed Size Content</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        html, body {
            width: 100%;
            height: 100%;
            overflow: hidden;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background: transparent;
        }
        
        .fixed-container {
            width: ${containerWidth}px;
            height: ${containerHeight}px;
            overflow: hidden;
            position: relative;
            padding: 12px;
            background: white;
            border-radius: 8px;
        }
        
        .scrollable-content {
            width: 100%;
            height: 100%;
            overflow-y: auto;
            overflow-x: hidden;
            scrollbar-width: thin;
            scrollbar-color: #ccc transparent;
        }
        
        .scrollable-content::-webkit-scrollbar {
            width: 4px;
        }
        
        .scrollable-content::-webkit-scrollbar-track {
            background: transparent;
        }
        
        .scrollable-content::-webkit-scrollbar-thumb {
            background: #ccc;
            border-radius: 2px;
        }
        
        .scrollable-content::-webkit-scrollbar-thumb:hover {
            background: #999;
        }
        
        /* Base content styles */
        .content-wrapper {
            font-size: 14px;
            line-height: 1.5;
            color: #333;
            word-wrap: break-word;
            overflow-wrap: break-word;
        }
        
        /* Typography */
        h1, h2, h3, h4, h5, h6 {
            margin: 12px 0 6px 0;
            font-weight: 600;
            line-height: 1.3;
        }
        h1 { font-size: 20px; }
        h2 { font-size: 18px; }
        h3 { font-size: 16px; }
        h4 { font-size: 15px; }
        h5, h6 { font-size: 14px; }
        
        p {
            margin: 6px 0;
            line-height: 1.5;
        }
        
        /* Lists */
        ul, ol {
            margin: 6px 0;
            padding-left: 20px;
        }
        li {
            margin: 2px 0;
        }
        
        /* Links */
        a {
            color: #007AFF;
            text-decoration: none;
            cursor: pointer;
        }
        a:hover {
            text-decoration: underline;
        }
        
        /* Images - constrained to container */
        img {
            max-width: 100%;
            height: auto;
            border-radius: 4px;
            margin: 4px 0;
        }
        
        /* Tables - responsive within fixed container */
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 8px 0;
            font-size: 12px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            border-radius: 4px;
            overflow: hidden;
        }
        th, td {
            padding: 6px 8px;
            text-align: left;
            border-bottom: 1px solid #e5e5e5;
            font-size: 11px;
        }
        th {
            background-color: #f8f9fa;
            font-weight: 600;
            color: #495057;
        }
        tr:nth-child(even) {
            background-color: #f8f9fa;
        }
        
        /* Forms - compact for fixed size */
        form {
            margin: 8px 0;
        }
        input, select, textarea, button {
            font-family: inherit;
            font-size: 13px;
            border-radius: 4px;
            border: 1px solid #d1d5db;
            padding: 6px 8px;
            margin: 2px 0;
            width: 100%;
            box-sizing: border-box;
        }
        input:focus, select:focus, textarea:focus {
            outline: none;
            border-color: #3b82f6;
            box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.1);
        }
        button {
            background-color: #3b82f6;
            color: white;
            border: none;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.2s;
            padding: 8px 12px;
        }
        button:hover {
            background-color: #2563eb;
        }
        button:active {
            transform: scale(0.98);
        }
        
        label {
            display: block;
            margin-bottom: 3px;
            font-weight: 500;
            color: #374151;
            font-size: 12px;
        }
        
        textarea {
            resize: vertical;
            min-height: 40px;
            max-height: 80px;
        }
        
        /* Code - compact */
        pre, code {
            font-family: 'SF Mono', Monaco, Inconsolata, 'Roboto Mono', Consolas, 'Courier New', monospace;
            background: #f8f9fa;
            border-radius: 3px;
        }
        code {
            padding: 1px 4px;
            font-size: 11px;
        }
        pre {
            padding: 8px;
            overflow-x: auto;
            margin: 6px 0;
            border-left: 2px solid #3b82f6;
            font-size: 11px;
        }
        
        /* Blockquotes - compact */
        blockquote {
            border-left: 3px solid #e5e5e5;
            padding-left: 12px;
            margin: 8px 0;
            color: #6b7280;
            font-style: italic;
        }
        
        /* Utility classes for fixed container */
        .flex { display: flex; }
        .items-center { align-items: center; }
        .justify-center { justify-content: center; }
        .justify-between { justify-content: space-between; }
        .flex-col { flex-direction: column; }
        .gap-1 { gap: 4px; }
        .gap-2 { gap: 8px; }
        
        .grid { display: grid; }
        .grid-cols-2 { grid-template-columns: repeat(2, 1fr); }
        .grid-cols-3 { grid-template-columns: repeat(3, 1fr); }
        
        /* Compact spacing */
        .m-1 { margin: 2px; }
        .m-2 { margin: 4px; }
        .p-1 { padding: 2px; }
        .p-2 { padding: 4px; }
        .p-4 { padding: 8px; }
        .mb-1 { margin-bottom: 2px; }
        .mb-2 { margin-bottom: 4px; }
        .mb-4 { margin-bottom: 8px; }
        
        /* Colors */
        .text-red-600 { color: #dc2626; }
        .text-green-600 { color: #059669; }
        .text-blue-600 { color: #2563eb; }
        .text-gray-500 { color: #6b7280; }
        .text-gray-600 { color: #4b5563; }
        .bg-red-50 { background-color: #fef2f2; }
        .bg-green-50 { background-color: #f0fdf4; }
        .bg-blue-50 { background-color: #eff6ff; }
        .bg-gray-50 { background-color: #f9fafb; }
        .bg-white { background-color: white; }
        
        /* Width utilities */
        .w-full { width: 100%; }
        .w-1\\/2 { width: 50%; }
        
        /* Border utilities */
        .rounded { border-radius: 4px; }
        .rounded-lg { border-radius: 8px; }
        .border { border: 1px solid #e5e7eb; }
        .border-gray-300 { border-color: #d1d5db; }
        
        /* Shadow utilities */
        .shadow { box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1); }
        .shadow-lg { box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); }
        
        /* Font utilities */
        .font-semibold { font-weight: 600; }
        .font-bold { font-weight: 700; }
        .text-sm { font-size: 11px; }
        .text-lg { font-size: 15px; }
        .text-xl { font-size: 17px; }
        
        /* Patient card specific styles for fixed container */
        .patient-header {
            display: flex;
            align-items: center;
            margin-bottom: 6px;
        }
        .profile-img {
            width: 24px;
            height: 24px;
            border-radius: 50%;
            margin-right: 6px;
            background-color: #e5e7eb;
        }
        .doctor-name {
            color: #dc2626;
            font-weight: 600;
            font-size: 13px;
        }
        .patient-name {
            font-weight: 600;
            font-size: 16px;
            margin-bottom: 2px;
        }
        .patient-meta {
            font-size: 12px;
            color: #6b7280;
            margin-bottom: 8px;
        }
        .details-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 2px;
            margin-bottom: 12px;
            font-size: 11px;
        }
        .details-grid div {
            padding: 1px 0;
        }
    </style>
</head>
<body>
    <div class="fixed-container">
        <div class="scrollable-content">
            <div class="content-wrapper">
                $content
            </div>
        </div>
    </div>
    
    <script>
    (function() {
        'use strict';
        
        console.log('Fixed-size HTML setup started');
        
        // Form handling for fixed container
        function setupFormHandling() {
            const forms = document.querySelectorAll('form');
            forms.forEach(form => {
                form.addEventListener('submit', function(e) {
                    e.preventDefault();
                    
                    const formData = new FormData(form);
                    const data = {};
                    for (let [key, value] of formData.entries()) {
                        data[key] = value;
                    }
                    
                    if (window.FlutterChannel) {
                        window.FlutterChannel.postMessage(JSON.stringify({
                            type: 'formSubmit',
                            data: data
                        }));
                    }
                    
                    return false;
                });
            });
            
            const buttons = document.querySelectorAll('button');
            buttons.forEach(button => {
                if (button.type !== 'submit') {
                    button.addEventListener('click', function(e) {
                        const buttonData = {
                            text: button.textContent,
                            id: button.id,
                            className: button.className
                        };
                        
                        if (window.FlutterChannel) {
                            window.FlutterChannel.postMessage(JSON.stringify({
                                type: 'buttonClick',
                                data: buttonData
                            }));
                        }
                    });
                }
            });
        }
        
        // Link handling
        function setupLinkHandling() {
            const links = document.querySelectorAll('a');
            links.forEach(link => {
                link.addEventListener('click', function(e) {
                    e.preventDefault();
                    
                    if (window.FlutterChannel) {
                        window.FlutterChannel.postMessage(JSON.stringify({
                            type: 'linkClick',
                            url: link.href,
                            text: link.textContent
                        }));
                    }
                    
                    return false;
                });
            });
        }
        
        // Prevent problematic behaviors
        function setupPreventions() {
            document.body.style.userSelect = 'none';
            document.body.style.webkitUserSelect = 'none';
            document.body.style.webkitTouchCallout = 'none';
            
            document.addEventListener('contextmenu', function(e) {
                e.preventDefault();
                return false;
            });
            
            document.addEventListener('touchstart', function(e) {
                if (e.touches.length > 1) {
                    e.preventDefault();
                }
            }, { passive: false });
            
            let lastTouchEnd = 0;
            document.addEventListener('touchend', function(e) {
                const now = Date.now();
                if (now - lastTouchEnd <= 300) {
                    e.preventDefault();
                }
                lastTouchEnd = now;
            }, false);
        }
        
        // Initialize everything
        function initialize() {
            try {
                setupFormHandling();
                setupLinkHandling();
                setupPreventions();
                
                console.log('Fixed-size HTML setup completed successfully');
                
            } catch (error) {
                console.error('Initialization error:', error);
            }
        }
        
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initialize);
        } else {
            initialize();
        }
        
    })();
    </script>
</body>
</html>''';
  }

  void _handleJavaScriptMessage(String message) {
    try {
      final data = json.decode(message);
      final type = data['type'];

      switch (type) {
        case 'formSubmit':
          widget.onFormSubmit?.call(data['data']);
          log('Form submitted: ${data['data']}');
          break;

        case 'linkClick':
          widget.onLinkTap?.call(data['url']);
          log('Link clicked: ${data['url']}');
          break;

        case 'buttonClick':
          log('Button clicked: ${data['data']}');
          break;
      }
    } catch (e) {
      log('Error handling JavaScript message: $e');
    }
  }

  void _setupFixedSizeHtml() async {
    log('Fixed-size HTML setup completed for type: $htmlType');
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(height: 8),
            const Text(
              'Failed to load',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  hasError = false;
                  isLoading = true;
                });
                _loadProcessedHtml();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
              ),
              child: const Text('Retry', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return _buildErrorWidget();
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            SizedBox(
              width: widget.width,
              height: widget.height,
              child: WebViewWidget(controller: controller),
            ),
            if (isLoading)
              Container(
                width: widget.width,
                height: widget.height,
                color: Colors.white.withOpacity(0.95),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Loading...',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              top: 6,
              right: 6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(htmlType).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      htmlType.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // const SizedBox(width: 4),
                  // Container(
                  //   padding: const EdgeInsets.all(4),
                  //   decoration: BoxDecoration(
                  //     color: Colors.black.withOpacity(0.7),
                  //     borderRadius: BorderRadius.circular(3),
                  //   ),
                  //   child: GestureDetector(
                  //     onTap: () {
                  //       Navigator.of(context).push(
                  //         MaterialPageRoute(
                  //           builder: (context) => HtmlViewerScreen(
                  //             htmlContent: widget.htmlContent,
                  //             title: 'HTML Content',
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //     child: const Icon(
                  //       Icons.open_in_full,
                  //       size: 12,
                  //       color: Colors.white,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'patient_card':
        return Colors.green;
      case 'form':
        return Colors.blue;
      case 'table':
        return Colors.orange;
      case 'chart':
        return Colors.purple;
      case 'media':
        return Colors.pink;
      case 'document':
        return Colors.indigo;
      case 'full_page':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
