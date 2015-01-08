From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 05/15] batman-adv: kernel doc fix for distributed-arp-table.h
Date: Thu,  8 Jan 2015 16:15:10 +0100
Message-ID: <1420730120-9844-6-git-send-email-antonio@meshcoding.com>
References: <1420730120-9844-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@hundeboll.net>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:18667 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756484AbbAHPQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 10:16:31 -0500
In-Reply-To: <1420730120-9844-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Martin Hundeb=C3=B8ll <martin@hundeboll.net>

Signed-off-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Acked-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/distributed-arp-table.h | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/batman-adv/distributed-arp-table.h b/net/batman-adv/di=
stributed-arp-table.h
index d76e1d0..2fe0764 100644
--- a/net/batman-adv/distributed-arp-table.h
+++ b/net/batman-adv/distributed-arp-table.h
@@ -25,9 +25,7 @@
=20
 #include <linux/if_arp.h>
=20
-/**
- * BATADV_DAT_ADDR_MAX - maximum address value in the DHT space
- */
+/* BATADV_DAT_ADDR_MAX - maximum address value in the DHT space */
 #define BATADV_DAT_ADDR_MAX ((batadv_dat_addr_t)~(batadv_dat_addr_t)0)
=20
 void batadv_dat_status_update(struct net_device *net_dev);
--=20
2.2.1
