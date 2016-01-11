From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 08/53] perf tools: Add missing sources in perf's MANIFEST
Date: Mon, 11 Jan 2016 13:47:59 +0000
Message-ID: <1452520124-2073-9-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Jiri Olsa <jolsa@redhat.com>,
	Jiri Olsa <jolsa@kernel.org>, Wang Nan <wangnan0@huawei.com>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Olsa <jolsa@redhat.com>

Adding missing bitmap.[ch] sources to the MINIFEST file.

Link: http://lkml.kernel.org/n/tip-bkwplvnpk6s6a8zi1923dzuj@git.kernel.org
Signed-off-by: Jiri Olsa <jolsa@kernel.org>
Signed-off-by: Wang Nan <wangnan0@huawei.com>
---
 tools/perf/MANIFEST | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/tools/perf/MANIFEST b/tools/perf/MANIFEST
index ddf922f..2e1fa23 100644
--- a/tools/perf/MANIFEST
+++ b/tools/perf/MANIFEST
@@ -28,6 +28,7 @@ tools/lib/string.c
 tools/lib/symbol/kallsyms.c
 tools/lib/symbol/kallsyms.h
 tools/lib/find_bit.c
+tools/lib/bitmap.c
 tools/include/asm/atomic.h
 tools/include/asm/barrier.h
 tools/include/asm/bug.h
@@ -57,6 +58,7 @@ tools/include/linux/rbtree_augmented.h
 tools/include/linux/string.h
 tools/include/linux/types.h
 tools/include/linux/err.h
+tools/include/linux/bitmap.h
 include/asm-generic/bitops/arch_hweight.h
 include/asm-generic/bitops/const_hweight.h
 include/asm-generic/bitops/fls64.h
-- 
1.8.3.4
