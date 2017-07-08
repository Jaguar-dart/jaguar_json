// Copyright (c) 2017, teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'codec/codec.dart' as codec;
import 'codec_repo/codec_repo.dart' as codecRepo;
import 'decode/decode.dart' as decode;
import 'encode/encode.dart' as encode;
import 'decode_repo/decode_repo.dart' as decodeRepo;
import 'encode_repo/encode_repo.dart' as encodeRepo;
import 'functions/functions.dart' as functions;
import 'json_routes/json_routes.dart' as jsonRoutes;

main() async {
  await codec.main();
  await codecRepo.main();
  await decode.main();
  await encode.main();
  await decodeRepo.main();
  await encodeRepo.main();
  await functions.main();
  await jsonRoutes.main();
}
