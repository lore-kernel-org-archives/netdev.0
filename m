From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net-next V5 8/9] MAINTAINERS: Add entry for Altera Triple Speed Ethernet Driver
Date: Fri, 14 Mar 2014 09:04:46 -0500
Message-ID: <1394805887-22030-9-git-send-email-vbridgers2013@gmail.com>
References: <1394805887-22030-1-git-send-email-vbridgers2013@gmail.com>
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	rob@landley.net, vbridgers2013@gmail.com
To: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:45779 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754809AbaCNOJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 10:09:44 -0400
In-Reply-To: <1394805887-22030-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a MAINTAINERS entry covering the Altera Triple Speed
Ethernet Driver, with support for the MSGDMA and SGDMA
soft DMA IP components.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
V5: - No changes for V5

V4: - No changes to MAINTAINERS for V4

V3: - Reorder commits, otherwise no change to these files from V2

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
