From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 12/14] batman-adv: update copyright years for 2014
Date: Mon, 13 Jan 2014 23:31:36 +0100
Message-ID: <1389652298-472-13-git-send-email-antonio@meshcoding.com>
References: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:12292 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388AbaAMWyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 17:54:22 -0500
In-Reply-To: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Simon Wunderlich <sw@simonwunderlich.de>

Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/Makefile                | 2 +-
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
 net/batman-adv/fragmentation.c         | 2 +-
 net/batman-adv/fragmentation.h         | 2 +-
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
 net/batman-adv/network-coding.c        | 2 +-
 net/batman-adv/network-coding.h        | 2 +-
 net/batman-adv/originator.c            | 2 +-
 net/batman-adv/originator.h            | 2 +-
 net/batman-adv/packet.h                | 2 +-
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
 41 files changed, 41 insertions(+), 41 deletions(-)

diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index e595415..42df18f 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
+# Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
 #
 # Marek Lindner, Simon Wunderlich
 #
diff --git a/net/batman-adv/bat_algo.h b/net/batman-adv/bat_algo.h
index 92435bf..4e49666 100644
--- a/net/batman-adv/bat_algo.h
+++ b/net/batman-adv/bat_algo.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index fb196a0..921ac20 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index 89d3a5b..9586750 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2006-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2014 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/bitarray.h b/net/batman-adv/bitarray.h
index 685e0af..cc24073 100644
--- a/net/batman-adv/bitarray.h
+++ b/net/batman-adv/bitarray.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2006-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2014 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/br=
idge_loop_avoidance.c
index b164a07..5c0eda4 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2014 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich
  *
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/br=
idge_loop_avoidance.h
index 377dae0..43c985d 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2014 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich
  *
diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index 26cbf34..b758881 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2010-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/debugfs.h b/net/batman-adv/debugfs.h
index 981794f..37c4d6d 100644
--- a/net/batman-adv/debugfs.h
+++ b/net/batman-adv/debugfs.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2010-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/di=
stributed-arp-table.c
index 1d214cd..edee504 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2014 B.A.T.M.A.N. contributors:
  *
  * Antonio Quartulli
  *
diff --git a/net/batman-adv/distributed-arp-table.h b/net/batman-adv/di=
stributed-arp-table.h
index afa13ca..ac9be9b 100644
--- a/net/batman-adv/distributed-arp-table.h
+++ b/net/batman-adv/distributed-arp-table.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2014 B.A.T.M.A.N. contributors:
  *
  * Antonio Quartulli
  *
diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentat=
ion.c
index 43185ca..88df9b1 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2013-2014 B.A.T.M.A.N. contributors:
  *
  * Martin Hundeb=C3=B8ll <martin@hundeboll.net>
  *
diff --git a/net/batman-adv/fragmentation.h b/net/batman-adv/fragmentat=
ion.h
index 0347f0c..5d7a0e6 100644
--- a/net/batman-adv/fragmentation.h
+++ b/net/batman-adv/fragmentation.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2013-2014 B.A.T.M.A.N. contributors:
  *
  * Martin Hundeb=C3=B8ll <martin@hundeboll.net>
  *
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_c=
lient.c
index 9ece204..55cf226 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_c=
lient.h
index 006befb..7ee53bb 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_c=
ommon.c
index f76816c..6f5e621 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/gateway_common.h b/net/batman-adv/gateway_c=
ommon.h
index c47b17a..aa51165 100644
--- a/net/batman-adv/gateway_common.h
+++ b/net/batman-adv/gateway_common.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-inte=
rface.c
index 3f0e41a..1b12573 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-inte=
rface.h
index ccd42c2..1918cd5 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/hash.c b/net/batman-adv/hash.c
index d9cfa03..63bdf7e 100644
--- a/net/batman-adv/hash.c
+++ b/net/batman-adv/hash.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2006-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2014 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index df5ece9..539fc12 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2006-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2014 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.=
c
index b384cb8..abb9d6e 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/icmp_socket.h b/net/batman-adv/icmp_socket.=
h
index 559e54a..0c33950 100644
--- a/net/batman-adv/icmp_socket.h
+++ b/net/batman-adv/icmp_socket.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index ad6aeed..e56b4d6 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 49a2394..412c77f 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-c=
oding.c
index 6a0b328..f1b604d 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2012-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2012-2014 B.A.T.M.A.N. contributors:
  *
  * Martin Hundeb=C3=B8ll, Jeppe Ledet-Pedersen
  *
diff --git a/net/batman-adv/network-coding.h b/net/batman-adv/network-c=
oding.h
index 136db6d..358c0d6 100644
--- a/net/batman-adv/network-coding.h
+++ b/net/batman-adv/network-coding.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2012-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2012-2014 B.A.T.M.A.N. contributors:
  *
  * Martin Hundeb=C3=B8ll, Jeppe Ledet-Pedersen
  *
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 5ed037f..6df12a2 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index ad17c3c..37be290 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index ef2010c..0a381d1 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 153065a..1ed9f7c 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 8fa23fc..557d3d1 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index c93b92d..579f5f0 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index 0b17f8d..aaddaa9 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 2dc2270..f82c267 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-inte=
rface.h
index 4ab0167..dbab22f 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index b6a4403..e456bf6 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2010-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/sysfs.h b/net/batman-adv/sysfs.h
index ed80b72..b715b60 100644
--- a/net/batman-adv/sysfs.h
+++ b/net/batman-adv/sysfs.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2010-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/transl=
ation-table.c
index ec89a1b..a6fb1ff 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich, Antonio Quartulli
  *
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/transl=
ation-table.h
index daa8ab7..20a1d78 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich, Antonio Quartulli
  *
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 8a1fa16..b53f90d 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
--=20
1.8.5.2
