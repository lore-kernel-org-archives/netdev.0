From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 02/16] batman-adv: update copyright years for 2015
Date: Fri, 29 May 2015 11:05:14 +0200
Message-ID: <1432890328-8247-3-git-send-email-antonio@meshcoding.com>
References: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:13380 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755683AbbE2JaN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2015 05:30:13 -0400
In-Reply-To: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
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
index eb7d8c03..79833eb 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
+# Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
 #
 # Marek Lindner, Simon Wunderlich
 #
diff --git a/net/batman-adv/bat_algo.h b/net/batman-adv/bat_algo.h
index 4e49666..4e59cf3 100644
--- a/net/batman-adv/bat_algo.h
+++ b/net/batman-adv/bat_algo.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 00e00e0..fc299c0 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index e3da07a..40e4a2a 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2006-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2015 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/bitarray.h b/net/batman-adv/bitarray.h
index 2acaafe..be497be 100644
--- a/net/batman-adv/bitarray.h
+++ b/net/batman-adv/bitarray.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2006-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2015 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/br=
idge_loop_avoidance.c
index ac4b96e..fa941cd 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2015 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich
  *
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/br=
idge_loop_avoidance.h
index 43c985d..1f506d3 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2015 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich
  *
diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index a4972874..0c213a8 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2010-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/debugfs.h b/net/batman-adv/debugfs.h
index 37c4d6d..f3b49c3 100644
--- a/net/batman-adv/debugfs.h
+++ b/net/batman-adv/debugfs.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2010-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/di=
stributed-arp-table.c
index aad022d..da1742d 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2015 B.A.T.M.A.N. contributors:
  *
  * Antonio Quartulli
  *
diff --git a/net/batman-adv/distributed-arp-table.h b/net/batman-adv/di=
stributed-arp-table.h
index 2fe0764..ed41b8e 100644
--- a/net/batman-adv/distributed-arp-table.h
+++ b/net/batman-adv/distributed-arp-table.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2015 B.A.T.M.A.N. contributors:
  *
  * Antonio Quartulli
  *
diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentat=
ion.c
index 3d1dcaa..af495cc 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2013-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2013-2015 B.A.T.M.A.N. contributors:
  *
  * Martin Hundeb=C3=B8ll <martin@hundeboll.net>
  *
diff --git a/net/batman-adv/fragmentation.h b/net/batman-adv/fragmentat=
ion.h
index d848cf6..ec1e86f 100644
--- a/net/batman-adv/fragmentation.h
+++ b/net/batman-adv/fragmentation.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2013-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2013-2015 B.A.T.M.A.N. contributors:
  *
  * Martin Hundeb=C3=B8ll <martin@hundeboll.net>
  *
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_c=
lient.c
index 090828c..a85eaca 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_c=
lient.h
index 7ee53bb..185fb08 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_c=
ommon.c
index 88a1bc3..0792e2f 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/gateway_common.h b/net/batman-adv/gateway_c=
ommon.h
index aa51165..df54342 100644
--- a/net/batman-adv/gateway_common.h
+++ b/net/batman-adv/gateway_common.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-inte=
rface.c
index baf1f98..bdb020e 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-inte=
rface.h
index 1918cd5..e8b6ffe 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/hash.c b/net/batman-adv/hash.c
index 7c1c630..3a0e1dc 100644
--- a/net/batman-adv/hash.c
+++ b/net/batman-adv/hash.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2006-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2015 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index 539fc12..379e32a 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2006-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2015 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.=
c
index 161ef8f..6c3cfb5 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/icmp_socket.h b/net/batman-adv/icmp_socket.=
h
index 0c33950..4815824 100644
--- a/net/batman-adv/icmp_socket.h
+++ b/net/batman-adv/icmp_socket.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 12fc77b..ca63d48 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 9d5657e..11d2d9f 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index b24e4bb..09f2838 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2014-2015 B.A.T.M.A.N. contributors:
  *
  * Linus L=C3=BCssing
  *
diff --git a/net/batman-adv/multicast.h b/net/batman-adv/multicast.h
index 3a44ebd..033d80e 100644
--- a/net/batman-adv/multicast.h
+++ b/net/batman-adv/multicast.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2014-2015 B.A.T.M.A.N. contributors:
  *
  * Linus L=C3=BCssing
  *
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-c=
oding.c
index 127cc4d..89e1d47 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2012-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2012-2015 B.A.T.M.A.N. contributors:
  *
  * Martin Hundeb=C3=B8ll, Jeppe Ledet-Pedersen
  *
diff --git a/net/batman-adv/network-coding.h b/net/batman-adv/network-c=
oding.h
index 358c0d6..b5ab8ff 100644
--- a/net/batman-adv/network-coding.h
+++ b/net/batman-adv/network-coding.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2012-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2012-2015 B.A.T.M.A.N. contributors:
  *
  * Martin Hundeb=C3=B8ll, Jeppe Ledet-Pedersen
  *
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 90e805a..e3900e4 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index aa4a436..9133914 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index b81fbbf..9468bc0 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index da83982..c5d9009 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 557d3d1..6573f12 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 3d64ed2..fa70ae8 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index 38d0ec1..60c233e 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 5ec31d7..d85a45c 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-inte=
rface.h
index dbab22f..9ce0804 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index a75dc12..fa8c347 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2010-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/sysfs.h b/net/batman-adv/sysfs.h
index b715b60..b9e79ad 100644
--- a/net/batman-adv/sysfs.h
+++ b/net/batman-adv/sysfs.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2010-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/transl=
ation-table.c
index 07b263a..b098e53 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich, Antonio Quartulli
  *
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/transl=
ation-table.h
index ad84d7b..5769037c 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich, Antonio Quartulli
  *
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 9398c3f..28f2461 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2014 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2015 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
--=20
2.4.2
