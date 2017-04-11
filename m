From: Alexander Alemayhu <alexander@alemayhu.com>
Subject: [PATCH net-next] bpf: add test_progs to .gitignore
Date: Tue, 11 Apr 2017 13:35:38 +0200
Message-ID: <20170411113538.31423-1-alexander@alemayhu.com>
Cc: daniel@iogearbox.net, ast@fb.com,
        Alexander Alemayhu <alexander@alemayhu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:33492 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751921AbdDKLfn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 07:35:43 -0400
Received: by mail-lf0-f48.google.com with SMTP id h125so85187628lfe.0
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 04:35:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>
---
 tools/testing/selftests/bpf/.gitignore | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tools/testing/selftests/bpf/.gitignore b/tools/testing/selftests/bpf/.gitignore
index 541d9d7fad5a..2fe8766e204f 100644
--- a/tools/testing/selftests/bpf/.gitignore
+++ b/tools/testing/selftests/bpf/.gitignore
@@ -3,3 +3,4 @@ test_maps
 test_lru_map
 test_lpm_map
 test_tag
+test_progs
-- 
2.9.3
