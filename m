From: "Oskar Schirmer" <oskar@scara.com>
Subject: [PATCH 3/5] net: Change mail address of Oskar Schirmer
Date: 16 May 2012 09:41:18 +0000
Message-ID: <1337161280-28953-4-git-send-email-oskar@scara.com>
References: <1337161280-28953-1-git-send-email-oskar@scara.com>
Cc: trivial@kernel.org, hannes@cmpxchg.org, shess@hessware.de,
	"Oskar Schirmer" <oskar@scara.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from skyrme.org ([193.175.80.135]:36899 "EHLO skyrme.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966856Ab2EPKXP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2012 06:23:15 -0400
Received: from p4ff1b755.dip.t-dialin.net ([79.241.183.85] helo=curry.scara.com)
	by skyrme.org with esmtpsa (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <oskar@curry.scara.com>)
	id 1SUaja-0003cp-AO
	for netdev@vger.kernel.org; Wed, 16 May 2012 09:41:30 +0000
In-Reply-To: <1337161280-28953-1-git-send-email-oskar@scara.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That old mail address doesnt exist any more.
This changes all occurences to my new address.

Signed-off-by: Oskar Schirmer <oskar@scara.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/s6gmac.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/s6gmac.c b/drivers/net/ethernet/s6gmac.c
index 1895605..6f0d284 100644
--- a/drivers/net/ethernet/s6gmac.c
+++ b/drivers/net/ethernet/s6gmac.c
@@ -1,7 +1,7 @@
 /*
  * Ethernet driver for S6105 on chip network device
  * (c)2008 emlix GmbH http://www.emlix.com
- * Authors:	Oskar Schirmer <os@emlix.com>
+ * Authors:	Oskar Schirmer <oskar@scara.com>
  *		Daniel Gloeckner <dg@emlix.com>
  *
  * This program is free software; you can redistribute it and/or
@@ -1070,4 +1070,4 @@ module_exit(s6gmac_exit);
 
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("S6105 on chip Ethernet driver");
-MODULE_AUTHOR("Oskar Schirmer <os@emlix.com>");
+MODULE_AUTHOR("Oskar Schirmer <oskar@scara.com>");
-- 
1.7.5.4
