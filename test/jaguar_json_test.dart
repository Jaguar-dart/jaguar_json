// Copyright (c) 2017, teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import 'codec/codec.dart' as codec;
import 'codec_repo/codec_repo.dart' as codecRepo;

main() async {
  await codec.main();
  await codecRepo.main();
  //TODO
}
