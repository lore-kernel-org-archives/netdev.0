From: Andrea Gelmini <andrea.gelmini@gelma.net>
Subject: [PATCH 059/199] Documentation/isdn/README.pcbit: Checkpatch cleanup
Date: Sun, 23 May 2010 21:50:23 +0200
Message-ID: <1274644226-23612-9-git-send-email-andrea.gelmini@gelma.net>
References: <1274644226-23612-1-git-send-email-andrea.gelmini@gelma.net>
Cc: Karsten Keil <isdn@linux-pingi.de>,
	Randy Dunlap <rdunlap@xenotime.net>, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
To: andrea.gelmini@gelma.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:9896 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754166Ab0EWTux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 May 2010 15:50:53 -0400
In-Reply-To: <1274644226-23612-1-git-send-email-andrea.gelmini@gelma.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Documentation/isdn/README.pcbit:10: ERROR: trailing whitespace
Documentation/isdn/README.pcbit:39: ERROR: trailing whitespace

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 Documentation/isdn/README.pcbit |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/isdn/README.pcbit b/Documentation/isdn/README.pcbit
index 5125002..6fe8f08 100644
--- a/Documentation/isdn/README.pcbit
+++ b/Documentation/isdn/README.pcbit
@@ -7,7 +7,7 @@ developed in cooperation with Portugal Telecom and Inesc.
 The driver interfaces with the standard kernel isdn facilities
 originally developed by Fritz Elfert in the isdn4linux project.
 
-The common versions of the pcbit board require a firmware that is 
+The common versions of the pcbit board require a firmware that is
 distributed (and copyrighted) by the manufacturer. To load this
 firmware you need "pcbitctl" available on the standard isdn4k-utils
 package or in the pcbit package available in:
@@ -36,5 +36,5 @@ mailing list (isdn4linux@listserv.isdn4linux.de) or directly from me.
 
 regards,
   Pedro.
-		
+
 <roque@di.fc.ul.pt>
-- 
1.7.1.251.gf80a2

