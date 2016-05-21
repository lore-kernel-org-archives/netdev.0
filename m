From: Andrea Gelmini <andrea.gelmini@gelma.net>
Subject: [PATCH 0051/1529] Fix typo
Date: Sat, 21 May 2016 13:43:40 +0200
Message-ID: <20160521114340.1693-1-andrea.gelmini@gelma.net>
Cc: trivial@kernel.org, klassert@mathematik.tu-chemnitz.de,
	corbet@lwn.net, netdev@vger.kernel.org, linux-doc@vger.kernel.org
To: andrea.gelmini@gelma.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:34760 "EHLO
	mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086AbcEULns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2016 07:43:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 Documentation/networking/vortex.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/networking/vortex.txt b/Documentation/networking/vortex.txt
index 97282da..40f1ab2 100644
--- a/Documentation/networking/vortex.txt
+++ b/Documentation/networking/vortex.txt
@@ -243,7 +243,7 @@ Media selection
 A number of the older NICs such as the 3c590 and 3c900 series have
 10base2 and AUI interfaces.
 
-Prior to January, 2001 this driver would autoeselect the 10base2 or AUI
+Prior to January, 2001 this driver would autoselect the 10base2 or AUI
 port if it didn't detect activity on the 10baseT port.  It would then
 get stuck on the 10base2 port and a driver reload was necessary to
 switch back to 10baseT.  This behaviour could not be prevented with a
-- 
2.8.2.534.g1f66975
