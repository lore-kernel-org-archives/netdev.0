From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 04/10] batman-adv: Rm empty line from is_my_mac() in main.c
Date: Fri, 17 Feb 2012 15:18:24 +0800
Message-ID: <1329463110-856-5-git-send-email-lindner_marek@yahoo.de>
References: <1329463110-856-1-git-send-email-lindner_marek@yahoo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@hundeboll.net>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm15-vm0.bullet.mail.ukl.yahoo.com ([217.146.183.252]:28716
	"HELO nm15-vm0.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751582Ab2BQHTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 02:19:12 -0500
In-Reply-To: <1329463110-856-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Martin Hundeb=C3=B8ll <martin@hundeboll.net>

Signed-off-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index fb87bdc..71b56cf 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -170,7 +170,6 @@ int is_my_mac(const uint8_t *addr)
 	}
 	rcu_read_unlock();
 	return 0;
-
 }
=20
 module_init(batman_init);
--=20
1.7.9
