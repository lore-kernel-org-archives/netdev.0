From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: [PATCH 3/8] batman-adv: Update copyright years
Date: Tue, 28 Feb 2012 19:32:23 +0800
Message-ID: <1330428748-23137-4-git-send-email-lindner_marek@yahoo.de>
References: <1330428748-23137-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1330428748-23137-1-git-send-email-lindner_marek-LWAfsSFWpa4@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
---
 net/batman-adv/Makefile            |    2 +-
 net/batman-adv/bat_algo.h          |    2 +-
 net/batman-adv/bat_debugfs.c       |    2 +-
 net/batman-adv/bat_debugfs.h       |    2 +-
 net/batman-adv/bat_iv_ogm.c        |    2 +-
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
index ce68611..4e392eb 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
+# Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
 #
 # Marek Lindner, Simon Wunderlich
 #
diff --git a/net/batman-adv/bat_algo.h b/net/batman-adv/bat_algo.h
index 755379f..9852a68 100644
--- a/net/batman-adv/bat_algo.h
+++ b/net/batman-adv/bat_algo.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2011-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.c
index a7a393e..c3b0548 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2010-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/bat_debugfs.h b/net/batman-adv/bat_debugfs.h
index bc9cda3..d605c67 100644
--- a/net/batman-adv/bat_debugfs.h
+++ b/net/batman-adv/bat_debugfs.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2010-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 1c483a5..2b66dae 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 480ae0a..7317729 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2010-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/bat_sysfs.h b/net/batman-adv/bat_sysfs.h
index a3f75a7..fece77a 100644
--- a/net/batman-adv/bat_sysfs.h
+++ b/net/batman-adv/bat_sysfs.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2010-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index 9bc63b2..e63069d 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2006-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2006-2012 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/bitarray.h b/net/batman-adv/bitarray.h
index 9c04422..c613572 100644
--- a/net/batman-adv/bitarray.h
+++ b/net/batman-adv/bitarray.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2006-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2006-2012 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index df5631e..65a77a1 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2009-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2009-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_client.h
index e1edba0..bf56a5a 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2009-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2009-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index c4ac7b0..7f79e15 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2009-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2009-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/gateway_common.h b/net/batman-adv/gateway_common.h
index 55e527a..b8fb11c 100644
--- a/net/batman-adv/gateway_common.h
+++ b/net/batman-adv/gateway_common.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2009-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2009-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index ff5ba40..41826b9 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index 67f78d1..e68c565 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/hash.c b/net/batman-adv/hash.c
index d1da29d..117687b 100644
--- a/net/batman-adv/hash.c
+++ b/net/batman-adv/hash.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2006-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2006-2012 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index 4768717..d4bd786 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2006-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2006-2012 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 5d69e10..9b755f9 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/icmp_socket.h b/net/batman-adv/icmp_socket.h
index 462b190..380ed4c 100644
--- a/net/batman-adv/icmp_socket.h
+++ b/net/batman-adv/icmp_socket.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 8ae497b..08f3b3a 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index ecfed88..6b276e1 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 1161f27..c2e46b5 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2009-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2009-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 67765ff..3fe2eda 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 88c717b..441f3db 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/ring_buffer.c b/net/batman-adv/ring_buffer.c
index f1ccfa7..fd63951 100644
--- a/net/batman-adv/ring_buffer.c
+++ b/net/batman-adv/ring_buffer.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/ring_buffer.h b/net/batman-adv/ring_buffer.h
index 7cdfe62..8b58bd8 100644
--- a/net/batman-adv/ring_buffer.h
+++ b/net/batman-adv/ring_buffer.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index c1e45c0..cf9a2f6 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 7aaee0f..92ac100 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 019337e..4137580 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index c8ca3ef..824ef06 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index c41dac3..2ffdc74 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
index 001546f..756eab5 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 30c2d1b..4dc5af3 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 30efd49..c753633 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 650ce5f..302efb5 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 6f3c659..0897dfa 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2010-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
  *
  * Andreas Langer
  *
diff --git a/net/batman-adv/unicast.h b/net/batman-adv/unicast.h
index 8fd5535..a9faf6b 100644
--- a/net/batman-adv/unicast.h
+++ b/net/batman-adv/unicast.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2010-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
  *
  * Andreas Langer
  *
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 4f4b2a0..c4a5b8c 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2008-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2008-2012 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich
  *
diff --git a/net/batman-adv/vis.h b/net/batman-adv/vis.h
index 851bc4f..ee2e46e 100644
--- a/net/batman-adv/vis.h
+++ b/net/batman-adv/vis.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2008-2011 B.A.T.M.A.N. contributors:
+ * Copyright (C) 2008-2012 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
-- 
1.7.9
