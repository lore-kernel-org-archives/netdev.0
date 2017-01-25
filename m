From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 6/7] batman-adv: update copyright years for 2017
Date: Wed, 25 Jan 2017 17:43:02 +0100
Message-ID: <20170125164303.14268-7-sw@simonwunderlich.de>
References: <20170125164303.14268-1-sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:49260 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751940AbdAYQnP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 11:43:15 -0500
In-Reply-To: <20170125164303.14268-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 include/uapi/linux/batman_adv.h        | 2 +-
 net/batman-adv/Makefile                | 2 +-
 net/batman-adv/bat_algo.c              | 2 +-
 net/batman-adv/bat_algo.h              | 2 +-
 net/batman-adv/bat_iv_ogm.c            | 2 +-
 net/batman-adv/bat_iv_ogm.h            | 2 +-
 net/batman-adv/bat_v.c                 | 2 +-
 net/batman-adv/bat_v.h                 | 2 +-
 net/batman-adv/bat_v_elp.c             | 2 +-
 net/batman-adv/bat_v_elp.h             | 2 +-
 net/batman-adv/bat_v_ogm.c             | 2 +-
 net/batman-adv/bat_v_ogm.h             | 2 +-
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
 net/batman-adv/log.c                   | 2 +-
 net/batman-adv/log.h                   | 2 +-
 net/batman-adv/main.c                  | 2 +-
 net/batman-adv/main.h                  | 2 +-
 net/batman-adv/multicast.c             | 2 +-
 net/batman-adv/multicast.h             | 2 +-
 net/batman-adv/netlink.c               | 2 +-
 net/batman-adv/netlink.h               | 2 +-
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
 net/batman-adv/tp_meter.c              | 2 +-
 net/batman-adv/tp_meter.h              | 2 +-
 net/batman-adv/translation-table.c     | 2 +-
 net/batman-adv/translation-table.h     | 2 +-
 net/batman-adv/tvlv.c                  | 2 +-
 net/batman-adv/tvlv.h                  | 2 +-
 net/batman-adv/types.h                 | 2 +-
 60 files changed, 60 insertions(+), 60 deletions(-)

diff --git a/include/uapi/linux/batman_adv.h b/include/uapi/linux/batman_adv.h
index 734fe83ab645..a83ddb7b63db 100644
--- a/include/uapi/linux/batman_adv.h
+++ b/include/uapi/linux/batman_adv.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2016 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2016-2017  B.A.T.M.A.N. contributors:
  *
  * Matthias Schiffer
  *
diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index f724d3c98a81..915987bc6d29 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+# Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
 #
 # Marek Lindner, Simon Wunderlich
 #
diff --git a/net/batman-adv/bat_algo.c b/net/batman-adv/bat_algo.c
index 623d04302aa2..44fd073b7546 100644
--- a/net/batman-adv/bat_algo.c
+++ b/net/batman-adv/bat_algo.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/bat_algo.h b/net/batman-adv/bat_algo.h
index 3b5b69cdd12b..29f6312f9bf1 100644
--- a/net/batman-adv/bat_algo.h
+++ b/net/batman-adv/bat_algo.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Linus Lüssing
  *
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index f00f666e2ccd..7c3d994e90d8 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/bat_iv_ogm.h b/net/batman-adv/bat_iv_ogm.h
index b9f3550faaf7..ae2ab526bdb1 100644
--- a/net/batman-adv/bat_iv_ogm.h
+++ b/net/batman-adv/bat_iv_ogm.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/bat_v.c b/net/batman-adv/bat_v.c
index 2ac612d7bab4..0acd081dd286 100644
--- a/net/batman-adv/bat_v.c
+++ b/net/batman-adv/bat_v.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2013-2016 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2013-2017  B.A.T.M.A.N. contributors:
  *
  * Linus Lüssing, Marek Lindner
  *
diff --git a/net/batman-adv/bat_v.h b/net/batman-adv/bat_v.h
index 83b77639729e..dd7c4b647e6b 100644
--- a/net/batman-adv/bat_v.h
+++ b/net/batman-adv/bat_v.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Linus Lüssing
  *
diff --git a/net/batman-adv/bat_v_elp.c b/net/batman-adv/bat_v_elp.c
index f2fb2f05b6bf..b90c9903e246 100644
--- a/net/batman-adv/bat_v_elp.c
+++ b/net/batman-adv/bat_v_elp.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2016 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2017  B.A.T.M.A.N. contributors:
  *
  * Linus Lüssing, Marek Lindner
  *
diff --git a/net/batman-adv/bat_v_elp.h b/net/batman-adv/bat_v_elp.h
index be17c0b1369e..376ead280ab9 100644
--- a/net/batman-adv/bat_v_elp.h
+++ b/net/batman-adv/bat_v_elp.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2013-2016 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2013-2017  B.A.T.M.A.N. contributors:
  *
  * Linus Lüssing, Marek Lindner
  *
diff --git a/net/batman-adv/bat_v_ogm.c b/net/batman-adv/bat_v_ogm.c
index 38b9aab83fc0..03a35c9f456d 100644
--- a/net/batman-adv/bat_v_ogm.c
+++ b/net/batman-adv/bat_v_ogm.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2013-2016 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2013-2017  B.A.T.M.A.N. contributors:
  *
  * Antonio Quartulli
  *
diff --git a/net/batman-adv/bat_v_ogm.h b/net/batman-adv/bat_v_ogm.h
index 4c4d45caa422..2068770b542d 100644
--- a/net/batman-adv/bat_v_ogm.h
+++ b/net/batman-adv/bat_v_ogm.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2013-2016 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2013-2017  B.A.T.M.A.N. contributors:
  *
  * Antonio Quartulli
  *
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index 032271421a20..2b070c7e31da 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2006-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2017  B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/bitarray.h b/net/batman-adv/bitarray.h
index 0e6e9d09078c..cc262c9d97e0 100644
--- a/net/batman-adv/bitarray.h
+++ b/net/batman-adv/bitarray.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2006-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2017  B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index e7f690b571ea..2d22fd5ba96c 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2017  B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich
  *
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/bridge_loop_avoidance.h
index 2827cd3c13d2..e157986bd01c 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2017  B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich
  *
diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index 77925504379d..5406148b9497 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2010-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/debugfs.h b/net/batman-adv/debugfs.h
index e49121ee55f6..9c5d4a65b98c 100644
--- a/net/batman-adv/debugfs.h
+++ b/net/batman-adv/debugfs.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2010-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 3641765d55df..942be77598d7 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2017  B.A.T.M.A.N. contributors:
  *
  * Antonio Quartulli
  *
diff --git a/net/batman-adv/distributed-arp-table.h b/net/batman-adv/distributed-arp-table.h
index 813ecea96cf9..ec364a3c1c66 100644
--- a/net/batman-adv/distributed-arp-table.h
+++ b/net/batman-adv/distributed-arp-table.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2011-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2017  B.A.T.M.A.N. contributors:
  *
  * Antonio Quartulli
  *
diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index 52396160360b..92e411d133ea 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2013-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2013-2017  B.A.T.M.A.N. contributors:
  *
  * Martin Hundebøll <martin@hundeboll.net>
  *
diff --git a/net/batman-adv/fragmentation.h b/net/batman-adv/fragmentation.h
index b95f619606af..1a2d6c308745 100644
--- a/net/batman-adv/fragmentation.h
+++ b/net/batman-adv/fragmentation.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2013-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2013-2017  B.A.T.M.A.N. contributors:
  *
  * Martin Hundebøll <martin@hundeboll.net>
  *
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 52b8bd6ec431..de9955d5224d 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_client.h
index 859166d03561..3baa3d466e5e 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index 21184810d89f..5db2e43e3775 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/gateway_common.h b/net/batman-adv/gateway_common.h
index 8a5e1ddf1175..0a6a97d201f2 100644
--- a/net/batman-adv/gateway_common.h
+++ b/net/batman-adv/gateway_common.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 61a431a9772b..e348f76ea8c1 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index d6309a423629..9f9890ff7a22 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/hash.c b/net/batman-adv/hash.c
index a0a0fdb85805..b5f7e13918ac 100644
--- a/net/batman-adv/hash.c
+++ b/net/batman-adv/hash.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2006-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2017  B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index 557a7044cfbc..0c905e91c5e2 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2006-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2017  B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index b310f381ae02..6308c9f0fd96 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/icmp_socket.h b/net/batman-adv/icmp_socket.h
index e44a7da51431..f3fec40aae86 100644
--- a/net/batman-adv/icmp_socket.h
+++ b/net/batman-adv/icmp_socket.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/log.c b/net/batman-adv/log.c
index c73c31769aba..4ef4bde2cc2d 100644
--- a/net/batman-adv/log.c
+++ b/net/batman-adv/log.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2010-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/log.h b/net/batman-adv/log.h
index 3284a7b0325d..7a2b9f4da078 100644
--- a/net/batman-adv/log.h
+++ b/net/batman-adv/log.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index d46415edd3be..5000c540614d 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 8683542067ba..57a8103dbce7 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index 090a69fc342e..952ba81a565b 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2014-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2014-2017  B.A.T.M.A.N. contributors:
  *
  * Linus Lüssing
  *
diff --git a/net/batman-adv/multicast.h b/net/batman-adv/multicast.h
index 2cddaf52a21d..2a78cddab0e9 100644
--- a/net/batman-adv/multicast.h
+++ b/net/batman-adv/multicast.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2014-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2014-2017  B.A.T.M.A.N. contributors:
  *
  * Linus Lüssing
  *
diff --git a/net/batman-adv/netlink.c b/net/batman-adv/netlink.c
index 062738163bdc..ab13b4d58733 100644
--- a/net/batman-adv/netlink.c
+++ b/net/batman-adv/netlink.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2016 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2016-2017  B.A.T.M.A.N. contributors:
  *
  * Matthias Schiffer
  *
diff --git a/net/batman-adv/netlink.h b/net/batman-adv/netlink.h
index 52eb16281aba..f1cd8c5da966 100644
--- a/net/batman-adv/netlink.h
+++ b/net/batman-adv/netlink.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2016 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2016-2017  B.A.T.M.A.N. contributors:
  *
  * Matthias Schiffer
  *
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index ab5a3bf0765f..e1f6fc72fe3e 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2012-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2012-2017  B.A.T.M.A.N. contributors:
  *
  * Martin Hundebøll, Jeppe Ledet-Pedersen
  *
diff --git a/net/batman-adv/network-coding.h b/net/batman-adv/network-coding.h
index d6d7fb4ec5d5..c66efb81d2f4 100644
--- a/net/batman-adv/network-coding.h
+++ b/net/batman-adv/network-coding.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2012-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2012-2017  B.A.T.M.A.N. contributors:
  *
  * Martin Hundebøll, Jeppe Ledet-Pedersen
  *
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 8f3b2969cc4e..8e2a4b205257 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2009-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index ebc56183f358..d94220a6d21a 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 7a36bcfa0ba0..8e8a5db197cb 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 9d657cff93de..bf5a0b9bed79 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 05c3ff42e181..5ede16c32f15 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 49021b7124f3..d7308263b8fa 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index a94e1e8639ca..f21166d10323 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 4e447bf17332..233a823a9008 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
index ec303ddbf647..639c3abb214a 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 17c844196eb2..0ae8b30e4eaa 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2010-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/sysfs.h b/net/batman-adv/sysfs.h
index c76021b4e198..e487412e256b 100644
--- a/net/batman-adv/sysfs.h
+++ b/net/batman-adv/sysfs.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2010-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
diff --git a/net/batman-adv/tp_meter.c b/net/batman-adv/tp_meter.c
index c367c8316a82..392a60d18584 100644
--- a/net/batman-adv/tp_meter.c
+++ b/net/batman-adv/tp_meter.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2012-2016 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2012-2017  B.A.T.M.A.N. contributors:
  *
  * Edo Monticelli, Antonio Quartulli
  *
diff --git a/net/batman-adv/tp_meter.h b/net/batman-adv/tp_meter.h
index ba922c425e56..a8ada5c123bd 100644
--- a/net/batman-adv/tp_meter.h
+++ b/net/batman-adv/tp_meter.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2012-2016 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2012-2017  B.A.T.M.A.N. contributors:
  *
  * Edo Monticelli, Antonio Quartulli
  *
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 30ecbfb40adf..941afad92121 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich, Antonio Quartulli
  *
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 783fdba84db2..411d586191da 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich, Antonio Quartulli
  *
diff --git a/net/batman-adv/tvlv.c b/net/batman-adv/tvlv.c
index a783420356ae..1d9e267caec9 100644
--- a/net/batman-adv/tvlv.c
+++ b/net/batman-adv/tvlv.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/tvlv.h b/net/batman-adv/tvlv.h
index e4369b547b43..4d01400ada30 100644
--- a/net/batman-adv/tvlv.h
+++ b/net/batman-adv/tvlv.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index e913aee28c98..8f64a5c01345 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1,4 +1,4 @@
-/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2017  B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
-- 
2.11.0
