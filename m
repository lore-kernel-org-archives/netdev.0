From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next] jme: Advance version number after previous changes
Date: Mon, 2 Mar 2009 16:39:25 +0800
Message-ID: <20090302083926.M60833@cooldavid.org>
References: <20080915165101.M68109@cooldavid.org> <48D27CDA.50501@pobox.com> <20081008215853.M53590@cooldavid.org>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=big5
Cc: netdev@vger.kernel.org, Ethan <ethanhsiao@jmicron.com>
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([220.133.139.86]:51031 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751873AbZCBIkk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 03:40:40 -0500
In-Reply-To: <20081008215853.M53590@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Advance version number after previous changes.
Sorry for not come along with previous patch series.

diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index e321c67..0996a06 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -25,7 +25,7 @@
 #define __JME_H_INCLUDED__
 
 #define DRV_NAME	"jme"
-#define DRV_VERSION	"1.0.3"
+#define DRV_VERSION	"1.0.4"
 #define PFX		DRV_NAME ": "
 
 #define PCI_DEVICE_ID_JMICRON_JMC250	0x0250

