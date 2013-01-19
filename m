From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 12/13] batman-adv: update copyright years
Date: Sat, 19 Jan 2013 21:27:58 +0800
Message-ID: <1358602079-24024-13-git-send-email-ordex@autistici.org>
References: <1358602079-24024-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:58396 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751923Ab3ASNaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2013 08:30:13 -0500
In-Reply-To: <1358602079-24024-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bat_algo.h              | 2 +-
 net/batman-adv/bat_iv_ogm.c            | 2 +-
 net/batman-adv/bitarray.c              | 2 +-
 net/batman-adv/bitarray.h              | 2 +-
 net/batman-adv/bridge_loop_avoidance.c | 2 +-
 net/batman-adv/bridge_loop_avoidance.h | 2 +-
 net/batman-adv/debugfs.c               | 2 +-
 net/batman-adv/debugfs.h               | 2 +-
 net/batman-adv/distributed-arp-table.c | 2 +-
 net/batman-adv/distributed-arp-table.h | 2 +-
 net/batman-adv/gateway_client.c        | 2 +-
 net/batman-adv/gateway_client.h        | 2 +-
 net/batman-adv/gateway_common.c        | 2 +-
 net/batman-adv/gateway_common.h        | 2 +-
 net/batman-adv/hard-interface.c        | 2 +-
 net/batman-adv/hard-interface.h        | 2 +-
 net/batman-adv/hash.c                  | 2 +-
 net/batman-adv/hash.h                  | 2 +-
 net/batman-adv/icmp_socket.c           | 2 +-
 net/batman-adv/icmp_socket.h           | 2 +-
 net/batman-adv/main.c                  | 2 +-
 net/batman-adv/main.h                  | 2 +-
 net/batman-adv/originator.c            | 2 +-
 net/batman-adv/originator.h            | 2 +-
 net/batman-adv/packet.h                | 2 +-
 net/batman-adv/ring_buffer.c           | 2 +-
 net/batman-adv/ring_buffer.h           | 2 +-
 net/batman-adv/routing.c               | 2 +-
 net/batman-adv/routing.h               | 2 +-
 net/batman-adv/send.c                  | 2 +-
 net/batman-adv/send.h                  | 2 +-
 net/batman-adv/soft-interface.c        | 2 +-
 net/batman-adv/soft-interface.h        | 2 +-
 net/batman-adv/sysfs.c                 | 2 +-
 net/batman-adv/sysfs.h                 | 2 +-
 net/batman-adv/translation-table.c     | 2 +-
 net/batman-adv/translation-table.h     | 2 +-
 net/batman-adv/types.h                 | 2 +-
 net/batman-adv/unicast.c               | 2 +-
 net/batman-adv/unicast.h               | 2 +-
 net/batman-adv/vis.c                   | 2 +-
 net/batman-adv/vis.h                   | 2 +-
 42 files changed, 42 insertions(+), 42 deletions(-)

diff --git a/net/batman-adv/bat_algo.h b/net/batman-adv/bat_algo.h
index a0ba3bf..a4808c2 100644
--- a/net/batman-adv/bat_algo.h
+++ b/net/batman-adv/bat_algo.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 36b9727..72fe1bb 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index 5453b17..9739824 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2006-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2013 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/bitarray.h b/net/batman-adv/bitarray.h
index cebaae7..a81b932 100644
--- a/net/batman-adv/bitarray.h
+++ b/net/batman-adv/bitarray.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2006-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2013 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 9971892..30f4652 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2013 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich
  *
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/bridge_loop_avoidance.h
index 196d9a0..dea2fbc 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2013 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich
  *
diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index e47555b..6ae8651 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/debugfs.h b/net/batman-adv/debugfs.h
index 3319e1f..f8c3849 100644
--- a/net/batman-adv/debugfs.h
+++ b/net/batman-adv/debugfs.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 8e1d89d..7485a78 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2013 B.A.T.M.A.N. contributors:
  *
  * Antonio Quartulli
  *
diff --git a/net/batman-adv/distributed-arp-table.h b/net/batman-adv/distributed-arp-table.h
index d060c03..125c8c6 100644
--- a/net/batman-adv/distributed-arp-table.h
+++ b/net/batman-adv/distributed-arp-table.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2013 B.A.T.M.A.N. contributors:
  *
  * Antonio Quartulli
  *
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index dd07c7e..074107f 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_client.h
index f0d129e..039902d 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index 9001208..84bb2b1 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/gateway_common.h b/net/batman-adv/gateway_common.h
index 13697f6..509b2bf 100644
--- a/net/batman-adv/gateway_common.h
+++ b/net/batman-adv/gateway_common.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index cb3191f..368219e 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index 3732366..308437d 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/hash.c b/net/batman-adv/hash.c
index 15a849c..7198daf 100644
--- a/net/batman-adv/hash.c
+++ b/net/batman-adv/hash.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2006-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2013 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index ea02148..1b4da72 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2006-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2013 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 87ca809..0ba6c89 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/icmp_socket.h b/net/batman-adv/icmp_socket.h
index 29443a1..1fcca37 100644
--- a/net/batman-adv/icmp_socket.h
+++ b/net/batman-adv/icmp_socket.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index f65a222..21fe698 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index af73d60..74eb960 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 92a55fd..457ea44 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 9778e65..286bf74 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index cb6405bf..ed0aa89 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/ring_buffer.c b/net/batman-adv/ring_buffer.c
index c8f61e3..ccab0bb 100644
--- a/net/batman-adv/ring_buffer.c
+++ b/net/batman-adv/ring_buffer.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/ring_buffer.h b/net/batman-adv/ring_buffer.h
index fda8c17..3f92ae2 100644
--- a/net/batman-adv/ring_buffer.h
+++ b/net/batman-adv/ring_buffer.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index db89238..60ba03f 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 9262279..99eeafa 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 0b6f65b..80ca65f 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index 0078dec..38e662f 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index c9962fe..2711e87 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
index 07a08fe..43182e5 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 84a55cb..afbba31 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/sysfs.h b/net/batman-adv/sysfs.h
index 3fd1412..479acf4 100644
--- a/net/batman-adv/sysfs.h
+++ b/net/batman-adv/sysfs.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 877acd1..fb15b4c 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich, Antonio Quartulli
  *
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 46d4451..ab8e683 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich, Antonio Quartulli
  *
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 8d4a16c..4cd87a0 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index f56bccf..50e079f 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2013 B.A.T.M.A.N. contributors:
  *
  * Andreas Langer
  *
diff --git a/net/batman-adv/unicast.h b/net/batman-adv/unicast.h
index 61abba5..429cf8a 100644
--- a/net/batman-adv/unicast.h
+++ b/net/batman-adv/unicast.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2013 B.A.T.M.A.N. contributors:
  *
  * Andreas Langer
  *
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 2e70ec1..22d2785 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2008-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2008-2013 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich
  *
diff --git a/net/batman-adv/vis.h b/net/batman-adv/vis.h
index 873282f..ad92b0e 100644
--- a/net/batman-adv/vis.h
+++ b/net/batman-adv/vis.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2008-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2008-2013 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
-- 
1.8.0.2
