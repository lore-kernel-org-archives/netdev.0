From: Karsten Keil <karsten-keil@t-online.de>
Subject: [PATCH v2 1/3] update Documentation/isdn/00-INDEX
Date: Thu, 23 Apr 2009 14:24:21 +0200
Message-ID: <992698ead1b2fe18791b0a25609310c89fa0adc9.1240489461.git.keil@b1-systems.de>
References: <cover.1240489461.git.keil@b1-systems.de>
Cc: Randy Dunlap <rdunlap@xenotime.net>,
	David Miller <davem@davemloft.net>, tilman@imap.cc,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout05.t-online.de ([194.25.134.82]:36886 "EHLO
	mailout05.t-online.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758255AbZDWMlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 08:41:50 -0400
In-Reply-To: <cover.1240489461.git.keil@b1-systems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Tue, 7 Apr 2009 17:51:32 +0200
After the merging of mISDN, state which files refer only to the
old isdn4linux subsystem.  Also add a few missing files.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 Documentation/isdn/00-INDEX |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/Documentation/isdn/00-INDEX b/Documentation/isdn/00-INDEX
index 9fee5f2..d9660ee 100644
--- a/Documentation/isdn/00-INDEX
+++ b/Documentation/isdn/00-INDEX
@@ -2,8 +2,12 @@
 	- this file (info on ISDN implementation for Linux)
 CREDITS
 	- list of the kind folks that brought you this stuff.
+HiSax.cert
+	- information about the ITU approval certification of the HiSax driver.
 INTERFACE
-	- description of Linklevel and Hardwarelevel ISDN interface.
+	- description of isdn4linux Link Level and Hardware Level interfaces.
+INTERFACE.fax
+	- description of the fax subinterface of isdn4linux.
 README
 	- general info on what you need and what to do for Linux ISDN.
 README.FAQ
@@ -12,6 +16,8 @@ README.audio
 	- info for running audio over ISDN.
 README.fax
 	- info for using Fax over ISDN.
+README.gigaset
+	- info on the drivers for Siemens Gigaset ISDN adapters.
 README.icn
 	- info on the ICN-ISDN-card and its driver.
 README.HiSax
@@ -37,7 +43,8 @@ README.diversion
 README.sc
 	- info on driver for Spellcaster cards.
 README.x25
-    _ info for running X.25 over ISDN.
+	- info for running X.25 over ISDN.
 README.hysdn
-        - info on driver for Hypercope active HYSDN cards
- 
+	- info on driver for Hypercope active HYSDN cards
+README.mISDN
+	- info on the Modular ISDN subsystem (mISDN).
-- 
1.6.0.2

