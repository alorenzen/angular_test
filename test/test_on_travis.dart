// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// The current Travis support for Dart - docs.travis-ci.com/user/languages/dart
// does not allow running one-off binaries. This file wraps
// `pub run angular_test` with a test that can be invoked on travis.
//
// The name – `test_on_travis.dart` is intentional. This file will not be run
// by the default `pub run test` flow. It is manually referenced in
// `.travis.yml`

import 'dart:async';
import 'dart:io';

import 'package:angular_test/src/util.dart';
import 'package:test/test.dart';

main() {
  var exec = 'pub';
  var args = [
    'run',
    'angular_test',
    // Use a specific port to avoid grabbing a bad one.
    '--serve-arg=--port=8080',
    '--test-arg=--timeout=4x',
    '--test-arg=--tags=aot',
    '--test-arg=--platform=dartium',
  ];
  var name = ([exec]..addAll(args)).join(' ');

  test(name, () async {
    var proc = await Process.start(exec, args);

    var values = await Future.wait(<Future>[
      proc.exitCode,
      standardIoToLines(proc.stdout).forEach(print),
      standardIoToLines(proc.stderr).forEach(print),
    ]);

    expect(values.first, 0, reason: "Expect exit code to be 0 (successs).");
  });
}
