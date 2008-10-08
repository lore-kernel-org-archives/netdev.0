From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6 3/3] jme: Advances version number
Date: Thu, 9 Oct 2008 05:58:53 +0800
Message-ID: <20081008215853.M53590@cooldavid.org>
References: <20080915165101.M68109@cooldavid.org> <48D27CDA.50501@pobox.com>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=big5
Cc: netdev@vger.kernel.org, Ethan <ethanhsiao@jmicron.com>,
	akeemting <akeem@jmicron.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 220-133-139-86.HINET-IP.hinet.net ([220.133.139.86]:34540 "EHLO
	cooldavid.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754742AbYJHV7U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 17:59:20 -0400
In-Reply-To: <48D27CDA.50501@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Jeff, David:

This patch:

    Advances the driver version after modification.

    The patch is also available at:
    http://cooldavid.org/download/jme.net-next-2.6.20081009.3.patch

    Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index 9fdf20a..f863aee 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -25,7 +25,7 @@
 #define __JME_H_INCLUDEE__
 
 #define DRV_NAME	"jme"
-#define DRV_VERSION	"1.0.2"
+#define DRV_VERSION	"1.0.3"
 #define PFX		DRV_NAME ": "
 
 #define PCI_DEVICE_ID_JMICRON_JMC250	0x0250

