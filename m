From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH v2] update Documentation/isdn/00-INDEX
Date: Mon, 17 Nov 2008 14:01:32 +0100
Message-ID: <20090407161650.51200111811@xenon.ts.pxnet.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([195.227.45.7]:40220 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755172AbZDGQRB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2009 12:17:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

sorry for the mistake in the preceding mail. That was an old,
incomplete version of the patch which won't even apply to the
current tree. Please disregard and use this one instead.

Thanks,
Tilman

ISDN: update Documentation/isdn/00-INDEX

After the merging of mISDN, state which files refer only to the
old isdn4linux subsystem. Also add a few missing files and sort
alphabetically.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 Documentation/isdn/00-INDEX |   45 ++++++++++++++++++++++++------------------
 1 files changed, 26 insertions(+), 19 deletions(-)

diff --git a/Documentation/isdn/00-INDEX b/Documentation/isdn/00-INDEX
index 9fee5f2..33543ac 100644
--- a/Documentation/isdn/00-INDEX
+++ b/Documentation/isdn/00-INDEX
@@ -2,28 +2,20 @@
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
 	- general info for FAQ.
-README.audio
-	- info for running audio over ISDN.
-README.fax
-	- info for using Fax over ISDN.
-README.icn
-	- info on the ICN-ISDN-card and its driver.
 README.HiSax
 	- info on the HiSax driver which replaces the old teles.
-README.hfc-pci
-	- info on hfc-pci based cards.
-README.pcbit
-	- info on the PCBIT-D ISDN adapter and driver.
-README.syncppp
-	- info on running Sync PPP over ISDN.
-syncPPP.FAQ
-	- frequently asked questions about running PPP over ISDN.
+README.audio
+	- info for running audio over ISDN.
 README.avmb1
 	- info on driver for AVM-B1 ISDN card.
 README.act2000
@@ -34,10 +26,25 @@ README.concap
 	- info on "CONCAP" encapsulation protocol interface used for X.25.
 README.diversion
 	- info on module for isdn diversion services.
+README.fax
+	- info for using Fax over ISDN.
+README.gigaset
+	- info on the drivers for Siemens Gigaset ISDN adapters
+README.hfc-pci
+	- info on hfc-pci based cards.
+README.hysdn
+        - info on driver for Hypercope active HYSDN cards
+README.icn
+	- info on the ICN-ISDN-card and its driver.
+README.mISDN
+	- info on the Modular ISDN subsystem (mISDN)
+README.pcbit
+	- info on the PCBIT-D ISDN adapter and driver.
 README.sc
 	- info on driver for Spellcaster cards.
+README.syncppp
+	- info on running Sync PPP over ISDN.
 README.x25
-    _ info for running X.25 over ISDN.
-README.hysdn
-        - info on driver for Hypercope active HYSDN cards
- 
+	- info on running X.25 over ISDN.
+syncPPP.FAQ
+	- frequently asked questions about running PPP over ISDN.
-- 
1.6.2.1.214.ge986c

