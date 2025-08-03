import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PatientCardWebView extends StatefulWidget {
  const PatientCardWebView({super.key});

  @override
  State<PatientCardWebView> createState() => _PatientCardWebViewState();
}

class _PatientCardWebViewState extends State<PatientCardWebView> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading progress
            debugPrint('WebView loading: $progress%');
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          // Handle messages from JavaScript
          _handleJavaScriptMessage(message.message);
        },
      );

    // Load your patient card HTML
    _loadPatientCard();
  }

  void _loadPatientCard() {
    // Option 1: Load from URL
    // _controller.loadRequest(Uri.parse('https://your-domain.com/patient-card'));

    // Option 2: Load HTML string directly
    const String htmlContent = '''
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Patient Card</title>
      <script src="https://cdn.tailwindcss.com"></script>
    </head>
    <body class="bg-gray-100 p-4">
      <div class="bg-white shadow-lg rounded-xl p-4 max-w-sm mx-auto">
        <!-- Patient Info -->
        <div class="flex items-center mb-4">
          <div class="w-10 h-10 rounded-full bg-blue-500 flex items-center justify-center text-white font-bold mr-3">
            S
          </div>
          <div>
            <div class="text-red-600 font-semibold">Dr. Sharafudeen</div>
            <div class="text-xs text-gray-500">Medical Examiner</div>
          </div>
        </div>
        
        <!-- Patient Details -->
        <div class="mb-4 p-3 bg-gray-50 rounded-lg">
          <div class="font-semibold text-lg text-gray-800">Rahul Kumar</div>
          <div class="text-sm text-gray-600">Male • 23 years</div>
          <div class="text-xs text-gray-500 mt-1">Ref: TBs1234567</div>
        </div>
        
        <!-- Status Selection -->
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-2">Status</label>
          <select id="statusSelect" class="w-full border rounded-md p-2 text-sm" onchange="updateStatus()">
            <option value="">Select Status...</option>
            <option value="fit">Fit</option>
            <option value="unfit">Unfit</option>
            <option value="pending">Pending</option>
            <option value="retest">Repeat Test</option>
          </select>
        </div>
        
        <!-- Remarks -->
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-2">Remarks</label>
          <textarea id="remarksText" rows="3" class="w-full border rounded-md p-2 text-sm" 
                    placeholder="Enter medical notes..."></textarea>
        </div>
        
        <!-- Action Buttons -->
        <div class="flex gap-2">
          <button onclick="submitForm()" 
                  class="flex-1 bg-green-600 text-white py-2 px-4 rounded-md text-sm font-medium hover:bg-green-700">
            Submit
          </button>
          <button onclick="clearForm()" 
                  class="flex-1 bg-gray-300 text-gray-700 py-2 px-4 rounded-md text-sm font-medium hover:bg-gray-400">
            Clear
          </button>
        </div>
        
        <!-- Status Display -->
        <div id="statusDisplay" class="mt-4 p-3 rounded-lg hidden">
          <div id="statusMessage" class="text-sm font-medium"></div>
        </div>
      </div>

      <script>
        function updateStatus() {
          const select = document.getElementById('statusSelect');
          const display = document.getElementById('statusDisplay');
          const message = document.getElementById('statusMessage');
          
          if (select.value) {
            message.textContent = 'Status: ' + select.options[select.selectedIndex].text;
            display.className = getStatusClass(select.value);
            display.classList.remove('hidden');
          } else {
            display.classList.add('hidden');
          }
        }
        
        function getStatusClass(status) {
          const baseClass = "mt-4 p-3 rounded-lg";
          switch(status) {
            case 'fit': return baseClass + " bg-green-100 text-green-800";
            case 'unfit': return baseClass + " bg-red-100 text-red-800";
            case 'pending': return baseClass + " bg-yellow-100 text-yellow-800";
            default: return baseClass + " bg-blue-100 text-blue-800";
          }
        }
        
        function submitForm() {
          const status = document.getElementById('statusSelect').value;
          const remarks = document.getElementById('remarksText').value;
          
          if (!status) {
            alert('Please select a status first!');
            return;
          }
          
          // Send data to Flutter
          if (window.FlutterChannel) {
            const data = {
              action: 'submit',
              patientId: 'TBs1234567',
              status: status,
              remarks: remarks,
              timestamp: new Date().toISOString()
            };
            window.FlutterChannel.postMessage(JSON.stringify(data));
          }
          
          // Show success message
          const display = document.getElementById('statusDisplay');
          const message = document.getElementById('statusMessage');
          message.textContent = '✓ Form submitted successfully!';
          display.className = "mt-4 p-3 rounded-lg bg-green-100 text-green-800";
          display.classList.remove('hidden');
        }
        
        function clearForm() {
          document.getElementById('statusSelect').value = '';
          document.getElementById('remarksText').value = '';
          document.getElementById('statusDisplay').classList.add('hidden');
          
          // Notify Flutter
          if (window.FlutterChannel) {
            window.FlutterChannel.postMessage(JSON.stringify({action: 'clear'}));
          }
        }
      </script>
    </body>
    </html>
    ''';

    _controller.loadHtmlString(htmlContent);
  }

  void _handleJavaScriptMessage(String message) {
    try {
      // Parse the JSON message from JavaScript
      final data = message; // You might want to parse JSON here
      debugPrint('Received from WebView: $data');

      // Handle different actions
      if (data.contains('submit')) {
        _handleFormSubmission(data);
      } else if (data.contains('clear')) {
        _handleFormClear();
      }
    } catch (e) {
      debugPrint('Error parsing WebView message: $e');
    }
  }

  void _handleFormSubmission(String data) {
    // Process form submission
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Patient form submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Here you would typically:
    // - Save to database
    // - Update patient records
    // - Navigate to next screen
    // - Send to API
  }

  void _handleFormClear() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form cleared'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _refreshWebView() async {
    await _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Execute JavaScript in the WebView
          _controller.runJavaScript('''
            document.getElementById('statusSelect').value = 'fit';
            updateStatus();
          ''');
        },
        backgroundColor: Colors.green.shade600,
        tooltip: 'Auto-fill Fit Status',
        child: const Icon(Icons.auto_fix_high, color: Colors.white),
      ),
    );
  }
}
