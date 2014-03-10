From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net-next v2 1/9] MAINTAINERS: Add entry for Altera Triple Speed Ethernet Driver
Date: Mon, 10 Mar 2014 18:14:29 -0500
Message-ID: <1394493277-2105-2-git-send-email-vbridgers2013@gmail.com>
References: <1394493277-2105-1-git-send-email-vbridgers2013@gmail.com>
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	rob@landley.net, vbridgers2013@gmail.com
To: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:40122 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753838AbaCJXTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 19:19:24 -0400
In-Reply-To: <1394493277-2105-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a MAINTAINERS entry covering the Altera Triple Speed
Ethernet Driver, with support for the MSGDMA and SGDMA
soft DMA IP components.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
V2: - Add a patch to update MAINTAINERS file, it was missed on the
      initial RFC submission.
---
 MAINTAINERS |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index e4ee191..cfa0dfa 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -536,6 +536,13 @@ S:	Odd Fixes
 L:	linux-alpha@vger.kernel.org
 F:	arch/alpha/
 
+ALTERA TRIPLE SPEED ETHERNET DRIVER
+M:	Vince Bridgers <vbridgers2013@gmail.com
+L:	netdev@vger.kernel.org
+L:	nios2-dev@lists.rocketboards.org (moderated for non-subscribers)
+S:	Maintained
+F:	drivers/net/ethernet/altera/
+
 ALTERA UART/JTAG UART SERIAL DRIVERS
 M:	Tobias Klauser <tklauser@distanz.ch>
 L:	linux-serial@vger.kernel.org
-- 
1.7.9.5
