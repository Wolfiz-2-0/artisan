import 'dart:io';
import 'package:artisan/extensions/color_print_extension.dart';
import 'package:artisan/functions/create_feature.dart';
import 'package:artisan/functions/update_router_paths.dart';
import 'package:artisan/functions/update_router_routes.dart';

Future<void> createView(String viewName, String featureName) async {
  try {
    // Determine the base path of the project dynamically
    final projectPath = Directory.current.path;

    // Define the directory for the feature correctly
    final featureDirectory =
        Directory('$projectPath/lib/features/$featureName/presentation/views');

    // Create the feature directory if it doesn't exist
    if (!await featureDirectory.exists()) {
       createFeature(featureName);
       'Feature not found, creating feature: $featureName'.printYellow();
      'NewFeature created: $featureName'.printGreen();
    }

    // Define the path for the new view file
    final viewFilePath = '${featureDirectory.path}/${viewName}_view.dart';

    // Check if the view file already exists
    if (await File(viewFilePath).exists()) {
      'Error: View file already exists: $viewFilePath'.printRed();
      return;
    }

    // Define the content for the view file, including the necessary imports
    final viewContent = '''
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:artisan_learning/util/router/paths.dart'; // Auto-import for paths

class ${viewName.capitalize()}View extends StatelessWidget {
  const ${viewName.capitalize()}View({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      height: 1.sh,
      color: Colors.indigoAccent,
      child: const Placeholder(),
    );
  }
}
''';

    // Write the new view content to the file
    await File(viewFilePath).writeAsString(viewContent);
    'View file created successfully: $viewFilePath'.printGreen();

    // Check and update router paths and routes
    final routerPathsResult = await updateRouterPaths(featureName, viewName);
    final routerResult = await updateRouterRoutes(featureName, viewName);

    // Check for existing paths and routes
    if (!routerPathsResult && !routerResult) {
      'Error: Both path and route already exist for ${viewName.capitalize()}View.'
          .printRed();
      // Clean up the created view file if paths or routes already existed
      await File(viewFilePath).delete();
      'View file deleted: $viewFilePath'.printRed();
    }
  } catch (e) {
    // Handle errors
    switch (e.runtimeType) {
      case FileSystemException:
        'Error: Unable to create or write to the view file.'.printRed();
        break;
      default:
        'An unknown error occurred: $e'.printRed();
    }
  }
}

// Extension to capitalize the first letter of a string
extension StringCapitalization on String {
  String capitalize() => this[0].toUpperCase() + this.substring(1);
}
