From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net-next 01/10] pktgen: Delete the original date from
 documentation
Date: Tue, 24 Feb 2015 02:31:13 +0000
Message-ID: <1424745073.4443.2.camel@xylophone.i.decadent.org.uk>
References: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:55252 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329AbbBXCbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 21:31:16 -0500
In-Reply-To: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This has been updated quite a few times since 2004, and git can
keep track of the actual date for us.

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 Documentation/networking/pktgen.txt |    2 --
 1 file changed, 2 deletions(-)

diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index 6915c6b27869..560c84ba9abd 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -3,8 +3,6 @@
                   HOWTO for the linux packet generator 
                   ------------------------------------
 
-Date: 041221
-
 Enable CONFIG_NET_PKTGEN to compile and build pktgen.o either in kernel
 or as module. Module is preferred. insmod pktgen if needed. Once running
 pktgen creates a thread on each CPU where each thread has affinity to its CPU.
-- 
1.7.10.4
