From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH] isdn: clean up documentation index
Date: Fri, 19 Jun 2009 20:24:53 +0200 (CEST)
Message-ID: <20090619182453.52725111835@xenon.ts.pxnet.com>
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Karsten Keil <karsten-keil@t-online.de>,
	isdn4linux@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([195.227.45.7]:52967 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751084AbZFSSZE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jun 2009 14:25:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove duplicates, a stray merge conflict marker, and an entry for a file
which doesn't exist, and move one entry to its correct alphabetical place.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 Documentation/isdn/00-INDEX |   19 ++-----------------
 1 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/Documentation/isdn/00-INDEX b/Documentation/isdn/00-INDEX
index f6010a5..e87e336 100644
--- a/Documentation/isdn/00-INDEX
+++ b/Documentation/isdn/00-INDEX
@@ -14,25 +14,14 @@ README
 	- general info on what you need and what to do for Linux ISDN.
 README.FAQ
 	- general info for FAQ.
-README.audio
-	- info for running audio over ISDN.
-README.fax
-	- info for using Fax over ISDN.
-README.gigaset
-	- info on the drivers for Siemens Gigaset ISDN adapters.
-README.icn
-	- info on the ICN-ISDN-card and its driver.
->>>>>>> 93af7aca44f0e82e67bda10a0fb73d383edcc8bd:Documentation/isdn/00-INDEX
 README.HiSax
 	- info on the HiSax driver which replaces the old teles.
+README.act2000
+	- info on driver for IBM ACT-2000 card.
 README.audio
 	- info for running audio over ISDN.
 README.avmb1
 	- info on driver for AVM-B1 ISDN card.
-README.act2000
-	- info on driver for IBM ACT-2000 card.
-README.eicon
-	- info on driver for Eicon active cards.
 README.concap
 	- info on "CONCAP" encapsulation protocol interface used for X.25.
 README.diversion
@@ -59,7 +48,3 @@ README.x25
 	- info for running X.25 over ISDN.
 syncPPP.FAQ
 	- frequently asked questions about running PPP over ISDN.
-README.hysdn
-	- info on driver for Hypercope active HYSDN cards
-README.mISDN
-	- info on the Modular ISDN subsystem (mISDN).
-- 
1.6.2.1.214.ge986c

