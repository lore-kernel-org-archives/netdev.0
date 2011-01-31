From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 8/9] batman-adv: Update copyright years
Date: Mon, 31 Jan 2011 16:20:50 +0100
Message-ID: <1296487251-12552-9-git-send-email-sven@narfation.org>
References: <1296487251-12552-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:42662 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755965Ab1AaPVd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 10:21:33 -0500
In-Reply-To: <1296487251-12552-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/Makefile            |    2 +-
 net/batman-adv/aggregation.c       |    2 +-
 net/batman-adv/aggregation.h       |    2 +-
 net/batman-adv/bat_debugfs.c       |    2 +-
 net/batman-adv/bat_debugfs.h       |    2 +-
 net/batman-adv/bat_sysfs.c         |    2 +-
 net/batman-adv/bat_sysfs.h         |    2 +-
 net/batman-adv/bitarray.c          |    2 +-
 net/batman-adv/bitarray.h          |    2 +-
 net/batman-adv/gateway_client.c    |    2 +-
 net/batman-adv/gateway_client.h    |    2 +-
 net/batman-adv/gateway_common.c    |    2 +-
 net/batman-adv/gateway_common.h    |    2 +-
 net/batman-adv/hard-interface.c    |    2 +-
 net/batman-adv/hard-interface.h    |    2 +-
 net/batman-adv/hash.c              |    2 +-
 net/batman-adv/hash.h              |    2 +-
 net/batman-adv/icmp_socket.c       |    2 +-
 net/batman-adv/icmp_socket.h       |    2 +-
 net/batman-adv/main.c              |    2 +-
 net/batman-adv/main.h              |    2 +-
 net/batman-adv/originator.c        |    2 +-
 net/batman-adv/originator.h        |    2 +-
 net/batman-adv/packet.h            |    2 +-
 net/batman-adv/ring_buffer.c       |    2 +-
 net/batman-adv/ring_buffer.h       |    2 +-
 net/batman-adv/routing.c           |    2 +-
 net/batman-adv/routing.h           |    2 +-
 net/batman-adv/send.c              |    2 +-
 net/batman-adv/send.h              |    2 +-
 net/batman-adv/soft-interface.c    |    2 +-
 net/batman-adv/soft-interface.h    |    2 +-
 net/batman-adv/translation-table.c |    2 +-
 net/batman-adv/translation-table.h |    2 +-
 net/batman-adv/types.h             |    2 +-
 net/batman-adv/unicast.c           |    2 +-
 net/batman-adv/unicast.h           |    2 +-
 net/batman-adv/vis.c               |    2 +-
 net/batman-adv/vis.h               |    2 +-
 39 files changed, 39 insertions(+), 39 deletions(-)

diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index d936aec..2de93d0 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+# Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
 #
 # Marek Lindner, Simon Wunderlich
 #
diff --git a/net/batman-adv/aggregation.c b/net/batman-adv/aggregation.c
index 3850a3e..1997725 100644
--- a/net/batman-adv/aggregation.c
+++ b/net/batman-adv/aggregation.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/aggregation.h b/net/batman-adv/aggregation.h
index 71a91b3..6ce305b 100644
--- a/net/batman-adv/aggregation.h
+++ b/net/batman-adv/aggregation.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.c
index d36d305..0e9d435 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2010-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/bat_debugfs.h b/net/batman-adv/bat_debugfs.h
index 72df532..bc9cda3 100644
--- a/net/batman-adv/bat_debugfs.h
+++ b/net/batman-adv/bat_debugfs.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2010-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index cd7bb51..f7b93a0 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2010-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/bat_sysfs.h b/net/batman-adv/bat_sysfs.h
index 7f186c0..02f1fa7 100644
--- a/net/batman-adv/bat_sysfs.h
+++ b/net/batman-adv/bat_sysfs.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2010-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index bbcd8f7..ad2ca92 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2006-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2006-2011 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/bitarray.h b/net/batman-adv/bitarray.h
index ac54017..769c246 100644
--- a/net/batman-adv/bitarray.h
+++ b/net/batman-adv/bitarray.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2006-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2006-2011 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 0065ffb..429a013 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2009-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2009-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_client.h
index 4585e65..2aa4391 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2009-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2009-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index b962982..50d3a59 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2009-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2009-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/gateway_common.h b/net/batman-adv/gateway_common.h
index 5e728d0..55e527a 100644
--- a/net/batman-adv/gateway_common.h
+++ b/net/batman-adv/gateway_common.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2009-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2009-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 8a9cf7a..f2131f4 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index a42f5a4..ad19543 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/hash.c b/net/batman-adv/hash.c
index 26e623e..fa26939 100644
--- a/net/batman-adv/hash.c
+++ b/net/batman-adv/hash.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2006-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2006-2011 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index 2f508e6..eae2440 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2006-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2006-2011 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index ecf6d7f..5e86d6f 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/icmp_socket.h b/net/batman-adv/icmp_socket.h
index bf9b348..08b1859 100644
--- a/net/batman-adv/icmp_socket.h
+++ b/net/batman-adv/icmp_socket.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index b827f6a..dc9248d 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index c1ace85..e235d7b 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 3c5c889..54863c9 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2009-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2009-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index d474ceb..8019fbd 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 03ce0d3..e757187 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/ring_buffer.c b/net/batman-adv/ring_buffer.c
index defd37c..5bb6a61 100644
--- a/net/batman-adv/ring_buffer.c
+++ b/net/batman-adv/ring_buffer.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/ring_buffer.h b/net/batman-adv/ring_buffer.h
index 6b0cb9a..0395b27 100644
--- a/net/batman-adv/ring_buffer.h
+++ b/net/batman-adv/ring_buffer.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 3b7e2f7..028f739 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 725cc38..ceeca6f 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 77f8297..7cc620e 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index c4cefa8..bc53ade 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index e89ede1..145e0f7 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
index 02b7733..e7b0e1a 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index a633b5a4..f6917dd 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 10c4c5c..a4f3a37 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index bf3f6f5..7270405 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index fc77079..cbf022c 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2010-2011 B.A.T.M.A.N. contributors:
  *
  * Andreas Langer
  *
diff --git a/net/batman-adv/unicast.h b/net/batman-adv/unicast.h
index e7211c2..8897308 100644
--- a/net/batman-adv/unicast.h
+++ b/net/batman-adv/unicast.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2010-2011 B.A.T.M.A.N. contributors:
  *
  * Andreas Langer
  *
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index cd4c423..a77b773 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2008-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2008-2011 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich
  *
diff --git a/net/batman-adv/vis.h b/net/batman-adv/vis.h
index 2c3b330..31b820d 100644
--- a/net/batman-adv/vis.h
+++ b/net/batman-adv/vis.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2008-2010 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2008-2011 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
-- 
1.7.2.3

