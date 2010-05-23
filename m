From: Andrea Gelmini <andrea.gelmini@gelma.net>
Subject: [PATCH 051/199] Documentation/isdn/HiSax.cert: Checkpatch cleanup
Date: Sun, 23 May 2010 21:50:15 +0200
Message-ID: <1274644226-23612-1-git-send-email-andrea.gelmini@gelma.net>
Cc: Karsten Keil <isdn@linux-pingi.de>,
	Randy Dunlap <rdunlap@xenotime.net>, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
To: andrea.gelmini@gelma.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:8538 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061Ab0EWTud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 May 2010 15:50:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Documentation/isdn/HiSax.cert:26: ERROR: trailing whitespace
Documentation/isdn/HiSax.cert:31: ERROR: trailing whitespace
Documentation/isdn/HiSax.cert:32: ERROR: trailing whitespace
Documentation/isdn/HiSax.cert:35: ERROR: trailing whitespace
Documentation/isdn/HiSax.cert:36: ERROR: trailing whitespace
Documentation/isdn/HiSax.cert:38: ERROR: trailing whitespace

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 Documentation/isdn/HiSax.cert |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/Documentation/isdn/HiSax.cert b/Documentation/isdn/HiSax.cert
index f2a6fcb..26ab655 100644
--- a/Documentation/isdn/HiSax.cert
+++ b/Documentation/isdn/HiSax.cert
@@ -23,19 +23,19 @@ therefore affect the certification.
 Additional ITU approval tests have been carried out for all generic cards
 using Colognechip single chip solutions HFC-S PCI A for PCI cards as well
 as HFC-S USB based USB ISDN ta adapters.
-These tests included all layers 1-3 and as well all functional tests for 
+These tests included all layers 1-3 and as well all functional tests for
 the layer 1. Because all hardware based on these chips are complete ISDN
 solutions in one chip all cards and USB-TAs using these chips are to be
 regarded as approved for those tests. Some additional electrical tests
 of the layer 1 which are independent of the driver and related to a
-special hardware used will be regarded as approved if at least one 
-solution has been tested including those electrical tests. So if cards 
+special hardware used will be regarded as approved if at least one
+solution has been tested including those electrical tests. So if cards
 or tas have been completely approved for any other os, the approval
 for those electrical tests is valid for linux, too.
-Please send any questions regarding this drivers or approval abouts to 
-werner@isdn-development.de 
+Please send any questions regarding this drivers or approval abouts to
+werner@isdn-development.de
 Additional information and the type approval documents will be found
-shortly on the Colognechip website www.colognechip.com 
+shortly on the Colognechip website www.colognechip.com
 
 If you change the main files of the HiSax ISDN stack, the certification will
 become invalid. Because in most countries it is illegal to connect
-- 
1.7.1.251.gf80a2

