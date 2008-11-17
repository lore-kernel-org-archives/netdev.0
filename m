From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH] update Documentation/isdn/00-INDEX
Date: Mon, 17 Nov 2008 14:01:32 +0100
Message-ID: <20090407155132.ADBEE111811@xenon.ts.pxnet.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([195.227.45.7]:37255 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753284AbZDGPvp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2009 11:51:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the merging of mISDN, state which files refer only to the
old isdn4linux subsystem.  Also add a few missing files.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 Documentation/isdn/00-INDEX |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/Documentation/isdn/00-INDEX b/Documentation/isdn/00-INDEX
index 9fee5f2..105cc6f 100644
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
@@ -37,8 +43,9 @@ README.diversion
 README.sc
 	- info on driver for Spellcaster cards.
 README.x25
-    _ info for running X.25 over ISDN.
+	- info on running X.25 over ISDN.
 README.hysdn
         - info on driver for Hypercope active HYSDN cards
- 
+README.mISDN
+	- info on the Modular ISDN subsystem (mISDN).
+
-- 
1.6.2.1.214.ge986c

