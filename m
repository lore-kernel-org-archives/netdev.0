From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 15/16] batman-adv: update copyright years for 2016
Date: Wed,  3 Feb 2016 10:18:36 +0800
Message-ID: <1454465917-13332-16-git-send-email-a__42291.3785944276$1454467540$gmane$org@unstable.cc>
References: <1454465917-13332-1-git-send-email-a@unstable.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:27289 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932572AbcBCCpV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 21:45:21 -0500
In-Reply-To: <1454465917-13332-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
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
 net/batman-adv/multicast.c             | 2 +-
 net/batman-adv/multicast.h             | 2 +-
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
 43 files changed, 43 insertions(+), 43 deletions(-)

diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index 21434ab79d2c..207e2af316c7 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
+# Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
 #
 # Marek Lindner, Simon Wunderlich
 #
diff --git a/net/batman-adv/bat_algo.h b/net/batman-adv/bat_algo.h
index 4e59cf3eb079..a7485d676088 100644
--- a/net/batman-adv/bat_algo.h
+++ b/net/batman-adv/bat_algo.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 7377313d3e42..3266bcb5bb06 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index 3404195f2561..b56bb000a0ab 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2006-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2016  B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/bitarray.h b/net/batman-adv/bitarray.h
index 2b64d7a1bc9b..3e41bb80eb81 100644
--- a/net/batman-adv/bitarray.h
+++ b/net/batman-adv/bitarray.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2006-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2016  B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/br=
idge_loop_avoidance.c
index b3a72e29a167..779160934844 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2016  B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich
  *
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/br=
idge_loop_avoidance.h
index 7ea199b8b5ab..579f0fa6fe6a 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2016  B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich
  *
diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index 0fc9df52f3d9..48253cf8341b 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2010-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/debugfs.h b/net/batman-adv/debugfs.h
index 80ab8d6f0ab3..1ab4e2e63afc 100644
--- a/net/batman-adv/debugfs.h
+++ b/net/batman-adv/debugfs.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2010-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/di=
stributed-arp-table.c
index 60df82385495..017fffe9a5b8 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2016  B.A.T.M.A.N. contributors:
  *
  * Antonio Quartulli
  *
diff --git a/net/batman-adv/distributed-arp-table.h b/net/batman-adv/di=
stributed-arp-table.h
index 26d4a525a798..813ecea96cf9 100644
--- a/net/batman-adv/distributed-arp-table.h
+++ b/net/batman-adv/distributed-arp-table.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2016  B.A.T.M.A.N. contributors:
  *
  * Antonio Quartulli
  *
diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentat=
ion.c
index 80eddf44a827..55656e84bc7e 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2013-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2013-2016  B.A.T.M.A.N. contributors:
  *
  * Martin Hundeb=C3=B8ll <martin@hundeboll.net>
  *
diff --git a/net/batman-adv/fragmentation.h b/net/batman-adv/fragmentat=
ion.h
index c5476fe79dc6..9ff77c7ef7c7 100644
--- a/net/batman-adv/fragmentation.h
+++ b/net/batman-adv/fragmentation.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2013-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2013-2016  B.A.T.M.A.N. contributors:
  *
  * Martin Hundeb=C3=B8ll <martin@hundeboll.net>
  *
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_c=
lient.c
index 83507750bb66..5950974de7b1 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_c=
lient.h
index fa9527785ed3..582dd8c413c8 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_c=
ommon.c
index b287448b9921..5ee04f7140af 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/gateway_common.h b/net/batman-adv/gateway_c=
ommon.h
index ab893e318229..b58346350024 100644
--- a/net/batman-adv/gateway_common.h
+++ b/net/batman-adv/gateway_common.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-inte=
rface.c
index 49e05d238667..db90022c00a4 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-inte=
rface.h
index 7b12ea8ea29d..4d6b5e12331f 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/hash.c b/net/batman-adv/hash.c
index 2ea6a18d793f..a0a0fdb85805 100644
--- a/net/batman-adv/hash.c
+++ b/net/batman-adv/hash.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2006-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2016  B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index 071a87ea4f2f..9bb57b87447c 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2006-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2016  B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.=
c
index bcabb5e3f4d3..a69da37bbad5 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/icmp_socket.h b/net/batman-adv/icmp_socket.=
h
index e937143f0b10..618d5de06f20 100644
--- a/net/batman-adv/icmp_socket.h
+++ b/net/batman-adv/icmp_socket.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 9d34be628304..5f319fd6ecd7 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 34f56efa2e4e..a7dc41a2709b 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index d984eee1776c..155565e0fecc 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2014-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2014-2016  B.A.T.M.A.N. contributors:
  *
  * Linus L=C3=BCssing
  *
diff --git a/net/batman-adv/multicast.h b/net/batman-adv/multicast.h
index 685219f3fec9..80bceec55592 100644
--- a/net/batman-adv/multicast.h
+++ b/net/batman-adv/multicast.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2014-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2014-2016  B.A.T.M.A.N. contributors:
  *
  * Linus L=C3=BCssing
  *
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-c=
oding.c
index 3a752bea55fa..0b30c15eee5f 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2012-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2012-2016  B.A.T.M.A.N. contributors:
  *
  * Martin Hundeb=C3=B8ll, Jeppe Ledet-Pedersen
  *
diff --git a/net/batman-adv/network-coding.h b/net/batman-adv/network-c=
oding.h
index 8f6d4ad8778a..d6d7fb4ec5d5 100644
--- a/net/batman-adv/network-coding.h
+++ b/net/batman-adv/network-coding.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2012-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2012-2016  B.A.T.M.A.N. contributors:
  *
  * Martin Hundeb=C3=B8ll, Jeppe Ledet-Pedersen
  *
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index f6ca4e509729..d4a30db0158a 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index cf0730414ed2..745b4e4fcdc4 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index fdb01637ad1f..e7f915181aba 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 1fb1be31bf3a..f4b60b1fb50e 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 204bbe4952a6..c776e9655b9b 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index c188f4660981..d8b03fd604e0 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index 3adc11fe1586..7ff95cada2e7 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 6c65de97126c..4bf35b8c3d23 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-inte=
rface.h
index 8e82176f40b1..d17cfbacf809 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index f38d7b75b0a5..964fc5986b2c 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2010-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/sysfs.h b/net/batman-adv/sysfs.h
index 61974428a7af..c76021b4e198 100644
--- a/net/batman-adv/sysfs.h
+++ b/net/batman-adv/sysfs.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2010-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/transl=
ation-table.c
index 9fcf6bf9fa11..0dc8a5ca33bf 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich, Antonio Quartulli
  *
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/transl=
ation-table.h
index abd8e116e5fb..7c7e2c006bfe 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich, Antonio Quartulli
  *
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 5e8c8df4c4ac..8974bc0dc15c 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
--=20
2.7.0
