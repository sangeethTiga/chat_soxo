import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AutoHeightHtmlWidget extends StatefulWidget {
  final String htmlContent;
  final double width;
  final double? minHeight;
  final double? maxHeight;
  final bool isSentMessage;
  final Function(Map<String, dynamic>)? onFormSubmit;
  final Function(String)? onLinkTap;
  final Function(String)? onImageTap;
  final Function(String)? onError;

  const AutoHeightHtmlWidget({
    super.key,
    required this.htmlContent,
    this.width = 350,
    this.minHeight = 100,
    this.maxHeight = 800,
    this.isSentMessage = false,
    this.onFormSubmit,
    this.onLinkTap,
    this.onImageTap,
    this.onError,
  });

  @override
  State<AutoHeightHtmlWidget> createState() => _AutoHeightHtmlWidgetState();
}

class _AutoHeightHtmlWidgetState extends State<AutoHeightHtmlWidget> {
  late final WebViewController controller;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  String htmlType = 'unknown';
  double currentHeight = 100;

  @override
  void initState() {
    super.initState();
    htmlType = _detectHtmlType(widget.htmlContent);
    currentHeight = widget.minHeight ?? 100;
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
      ..addJavaScriptChannel(
        'HeightChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _handleHeightChange(message.message);
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
            _setupAutoHeightHtml();
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

  void _handleHeightChange(String message) {
    try {
      final data = json.decode(message);
      if (data['type'] == 'heightChange') {
        double newHeight = data['height'].toDouble();

        // Apply min/max constraints
        if (widget.minHeight != null && newHeight < widget.minHeight!) {
          newHeight = widget.minHeight!;
        }
        if (widget.maxHeight != null && newHeight > widget.maxHeight!) {
          newHeight = widget.maxHeight!;
        }

        if (mounted && (newHeight - currentHeight).abs() > 5) {
          setState(() {
            currentHeight = newHeight;
          });
          log('Height updated to: $newHeight');
        }
      }
    } catch (e) {
      log('Error handling height change: $e');
    }
  }

  void _loadProcessedHtml() {
    try {
      String processedHtml = _processAutoHeightHtml(widget.htmlContent);
      log(
        'Loading auto-height HTML: $htmlType (${processedHtml.length} chars)',
      );
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

  String _processAutoHeightHtml(String htmlContent) {
    String content = htmlContent.trim().replaceAll('\r\n', '\n');
    content = _removeExternalResources(content);
    return _wrapInAutoHeightContainer(content);
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

  String _wrapInAutoHeightContainer(String content) {
    final containerWidth = widget.width - 24;

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Auto Height Content</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        html, body {
            width: 100%;
            min-height: 100%;
            overflow: hidden; /* Prevent scroll issues */
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background: white; /* Ensure white background */
            margin: 0;
            padding: 0;
        }
        
        .auto-container {
            width: ${containerWidth}px;
            min-height: fit-content;
            max-height: none; /* Remove height restrictions */
            padding: 12px;
            background: white;
            border-radius: 8px;
            overflow: visible; /* Allow content to be visible */
            position: relative;
        }
        
        .content-wrapper {
            width: 100%;
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
        
        /* Images - Fixed sizing to prevent layout jumps */
        img {
            max-width: 100%;
            max-height: 150px !important; /* Force consistent height */
            width: auto;
            height: auto;
            border-radius: 4px;
            margin: 4px 0;
            display: block;
            object-fit: cover;
        }
        
        /* Override any inline styles on images */
        .content-wrapper img {
            max-height: 150px !important;
            max-width: 100% !important;
            box-sizing: border-box;
        }
        
        /* Multiple images in a row */
        .images-row {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin: 8px 0;
        }
        
        .images-row img {
            flex: 1;
            min-width: 100px;
            max-width: calc(33.33% - 8px); /* 3 images per row */
            max-height: 120px;
            object-fit: cover;
        }
        
        /* Grid layout for multiple images */
        .images-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
            gap: 8px;
            margin: 8px 0;
        }
        
        .images-grid img {
            width: 100%;
            max-height: 120px;
            object-fit: cover;
        }
        
        /* Stack images vertically with smaller size */
        .images-stack img {
            max-height: 100px;
            width: 100%;
            object-fit: cover;
            margin: 4px 0;
        }
        
        /* Ensure images in flex/grid containers display properly */
        .flex img {
            flex-shrink: 0;
            max-height: 120px;
        }
        
        .grid img {
            max-height: 120px;
        }
        
        /* Responsive image sizing */
        @media (max-width: 400px) {
            img {
                max-height: 100px;
            }
            
            .images-row img {
                max-width: calc(50% - 4px); /* 2 images per row on small screens */
                max-height: 80px;
            }
        }
        
        /* Tables */
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
        
        /* Forms */
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
        }
        
        /* Code */
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
        
        /* Blockquotes */
        blockquote {
            border-left: 3px solid #e5e5e5;
            padding-left: 12px;
            margin: 8px 0;
            color: #6b7280;
            font-style: italic;
        }
        
        /* Utility classes */
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
        
        .w-full { width: 100%; }
        .w-1\\/2 { width: 50%; }
        
        .rounded { border-radius: 4px; }
        .rounded-lg { border-radius: 8px; }
        .border { border: 1px solid #e5e7eb; }
        .border-gray-300 { border-color: #d1d5db; }
        
        .shadow { box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1); }
        .shadow-lg { box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); }
        
        .font-semibold { font-weight: 600; }
        .font-bold { font-weight: 700; }
        .text-sm { font-size: 11px; }
        .text-lg { font-size: 15px; }
        .text-xl { font-size: 17px; }
        
        /* Patient card specific styles */
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
    <div class="auto-container" id="autoContainer">
        <div class="content-wrapper">
            $content
        </div>
    </div>
    
    <script>
    (function() {
        'use strict';
        
        console.log('Auto-height HTML setup started');
        
        let resizeObserver;
        let lastHeight = 0;
        
        function updateHeight() {
            const container = document.getElementById('autoContainer');
            if (container) {
                // Force a reflow to ensure accurate measurement
                container.style.height = 'auto';
                
                const height = Math.max(container.scrollHeight, container.offsetHeight) + 24;
                
                // Prevent infinite updates with a reasonable max height
                const maxAllowedHeight = 2000;
                const finalHeight = Math.min(height, maxAllowedHeight);
                
                if (Math.abs(finalHeight - lastHeight) > 10 && finalHeight > 50) {
                    lastHeight = finalHeight;
                    
                    if (window.HeightChannel) {
                        window.HeightChannel.postMessage(JSON.stringify({
                            type: 'heightChange',
                            height: finalHeight
                        }));
                    }
                    
                    console.log('Height updated:', finalHeight);
                }
            }
        }
        
        function organizeImages() {
            const container = document.getElementById('autoContainer');
            const images = container.querySelectorAll('img');
            
            if (images.length > 1) {
                console.log('Found', images.length, 'images, organizing layout...');
                
                // Group consecutive images together
                let imageGroups = [];
                let currentGroup = [];
                
                images.forEach((img, index) => {
                    // Check if this image is directly following the previous one
                    if (currentGroup.length === 0) {
                        currentGroup.push(img);
                    } else {
                        const prevImg = currentGroup[currentGroup.length - 1];
                        const nextSibling = prevImg.nextElementSibling;
                        
                        if (nextSibling === img || 
                            (nextSibling && nextSibling.nextElementSibling === img)) {
                            currentGroup.push(img);
                        } else {
                            if (currentGroup.length > 1) {
                                imageGroups.push([...currentGroup]);
                            }
                            currentGroup = [img];
                        }
                    }
                });
                
                if (currentGroup.length > 1) {
                    imageGroups.push(currentGroup);
                }
                
                // Create organized layout for groups
                imageGroups.forEach(group => {
                    if (group.length >= 2) {
                        const wrapper = document.createElement('div');
                        
                        if (group.length === 2) {
                            wrapper.className = 'images-row';
                        } else if (group.length === 3) {
                            wrapper.className = 'images-grid';
                            wrapper.style.gridTemplateColumns = 'repeat(3, 1fr)';
                        } else {
                            wrapper.className = 'images-grid';
                        }
                        
                        // Insert wrapper before first image
                        group[0].parentNode.insertBefore(wrapper, group[0]);
                        
                        // Move all images to wrapper
                        group.forEach(img => {
                            wrapper.appendChild(img);
                        });
                        
                        console.log('Created image group with', group.length, 'images');
                    }
                });
            }
        }
        
        function waitForImages() {
            return new Promise((resolve) => {
                const images = document.querySelectorAll('img');
                if (images.length === 0) {
                    console.log('No images found, proceeding...');
                    resolve();
                    return;
                }
                
                let loadedImages = 0;
                let erroredImages = 0;
                const totalImages = images.length;
                console.log('Waiting for', totalImages, 'images to load...');
                
                // Log all image sources for debugging
                images.forEach((img, index) => {
                    console.log('Image', index + 1, 'src:', img.src.substring(0, 100) + '...');
                });
                
                const imageProcessed = () => {
                    const processed = loadedImages + erroredImages;
                    console.log('Images processed:', processed + '/' + totalImages, 'loaded:', loadedImages, 'errored:', erroredImages);
                    
                    if (processed >= totalImages) {
                        setTimeout(() => {
                            organizeImages();
                            updateHeight();
                            resolve();
                        }, 300);
                    }
                };
                
                images.forEach((img, index) => {
                    // Set consistent max dimensions
                    img.style.maxHeight = '150px';
                    img.style.maxWidth = '100%';
                    img.style.objectFit = 'cover';
                    img.style.display = 'block';
                    
                    if (img.complete && img.naturalWidth > 0) {
                        console.log('Image', index + 1, 'already loaded');
                        loadedImages++;
                        imageProcessed();
                    } else {
                        img.onload = () => {
                            console.log('Image', index + 1, 'loaded successfully');
                            loadedImages++;
                            imageProcessed();
                        };
                        img.onerror = (error) => {
                            console.error('Image', index + 1, 'failed to load:', img.src);
                            console.error('Error details:', error);
                            // Replace broken image with placeholder
                            img.src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjE1MCIgdmlld0JveD0iMCAwIDIwMCAxNTAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIyMDAiIGhlaWdodD0iMTUwIiBmaWxsPSIjRjNGNEY2Ii8+CjxwYXRoIGQ9Ik04NS4zMzMzIDc1SDE1MEw5NCA0NUw4NS4zMzMzIDUzLjMzMzNMNjQgNDVMNTAgNzVIMTMzLjMzM1oiIGZpbGw9IiM2QjcyODAiLz4KPGNpcmNsZSBjeD0iNzAiIGN5PSI2MCIgcj0iNSIgZmlsbD0iIzZCNzI4MCIvPgo8dGV4dCB4PSIxMDAiIHk9IjEwMCIgZm9udC1mYW1pbHk9IkFyaWFsIiBmb250LXNpemU9IjEyIiBmaWxsPSIjNkI3MjgwIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIj5GYWlsZWQgdG8gbG9hZCBpbWFnZTwvdGV4dD4KPHN2Zz4K';
                            erroredImages++;
                            imageProcessed();
                        };
                    }
                });
                
                // Shorter timeout to prevent hanging
                setTimeout(() => {
                    if (loadedImages + erroredImages < totalImages) {
                        console.log('Image loading timeout, proceeding with partial load');
                        organizeImages();
                        updateHeight();
                        resolve();
                    }
                }, 2000);
            });
        }
        
        function setupHeightObserver() {
            const container = document.getElementById('autoContainer');
            if (!container) return;
            
            let isInitialized = false;
            let updateCount = 0;
            const MAX_UPDATES = 5; // Prevent infinite updates
            
            // Wait for images to load first
            waitForImages().then(() => {
                console.log('All images processed, setting up height observer');
                isInitialized = true;
                
                // Use ResizeObserver if available
                if (window.ResizeObserver) {
                    resizeObserver = new ResizeObserver((entries) => {
                        if (isInitialized && updateCount < MAX_UPDATES) {
                            updateCount++;
                            updateHeight();
                        }
                    });
                    resizeObserver.observe(container);
                }
                
                // Limited periodic checks instead of continuous monitoring
                const limitedChecks = () => {
                    if (updateCount < MAX_UPDATES) {
                        updateHeight();
                        setTimeout(limitedChecks, 2000); // Check every 2 seconds
                    } else {
                        console.log('Height observer reached max updates, stopping');
                    }
                };
                
                // Initial height update
                updateHeight();
                
                // Start limited checking after a delay
                setTimeout(limitedChecks, 1000);
            });
            
            // Handle dynamic content changes more carefully
            const observer = new MutationObserver((mutations) => {
                if (!isInitialized || updateCount >= MAX_UPDATES) return;
                
                let shouldUpdate = false;
                mutations.forEach((mutation) => {
                    if (mutation.type === 'childList') {
                        const addedImages = Array.from(mutation.addedNodes)
                            .filter(node => node.nodeType === 1)
                            .flatMap(node => {
                                if (node.tagName === 'IMG') return [node];
                                return Array.from(node.querySelectorAll('img'));
                            });
                        
                        if (addedImages.length > 0) {
                            console.log('New images detected, re-processing...');
                            shouldUpdate = true;
                        }
                    }
                });
                
                if (shouldUpdate) {
                    waitForImages();
                }
            });
            
            observer.observe(container, {
                childList: true,
                subtree: true
            });
        }
        
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
        
        function setupImageHandling() {
            const images = document.querySelectorAll('img');
            images.forEach(img => {
                img.style.cursor = 'pointer';
                img.addEventListener('click', function(e) {
                    e.preventDefault();
                    
                    if (window.FlutterChannel) {
                        window.FlutterChannel.postMessage(JSON.stringify({
                            type: 'imageClick',
                            src: img.src,
                            alt: img.alt || '',
                            width: img.naturalWidth,
                            height: img.naturalHeight
                        }));
                    }
                    
                    return false;
                });
            });
        }
        
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
        
        function initialize() {
            try {
                setupHeightObserver();
                setupFormHandling();
                setupLinkHandling();
                setupImageHandling();
                setupPreventions();
                
                console.log('Auto-height HTML setup completed successfully');
                
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

        case 'imageClick':
          widget.onImageTap?.call(data['src']);
          log('Image clicked: ${data['src']}');
          break;

        case 'buttonClick':
          log('Button clicked: ${data['data']}');
          break;
      }
    } catch (e) {
      log('Error handling JavaScript message: $e');
    }
  }

  void _setupAutoHeightHtml() async {
    log('Auto-height HTML setup completed for type: $htmlType');
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: currentHeight,
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: widget.width,
      height: currentHeight,
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
              height: currentHeight,
              child: WebViewWidget(controller: controller),
            ),
            if (isLoading)
              Container(
                width: widget.width,
                height: currentHeight,
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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
