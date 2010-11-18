From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next] MAINTAINERS: Add stmmac maintainer
Date: Thu, 18 Nov 2010 10:19:02 +0100
Message-ID: <1290071942-28179-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:43207 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751210Ab0KRJTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 04:19:12 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 9F00C92
	for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 09:19:08 +0000 (GMT)
Received: from mail1.ctn.st.com (mail1.ctn.st.com [164.130.116.128])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 552A01D4D
	for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 09:19:08 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add STMMAC to the list of supported Ethernet drivers
and myself as maintainer.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 MAINTAINERS |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 88b74a7..8b6ca96 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1829,6 +1829,13 @@ W:	http://www.chelsio.com
 S:	Supported
 F:	drivers/net/cxgb4vf/
 
+STMMAC ETHERNET DRIVER
+M:	Giuseppe Cavallaro <peppe.cavallaro@st.com>
+L:	netdev@vger.kernel.org
+W:	http://www.stlinux.com
+S:	Supported
+F:	drivers/net/stmmac/
+
 CYBERPRO FB DRIVER
 M:	Russell King <linux@arm.linux.org.uk>
 L:	linux-arm-kernel@lists.infradead.org (moderated for non-subscribers)
-- 
1.5.5.6

