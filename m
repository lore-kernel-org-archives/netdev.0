From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 5/5] forcedeth: bump version to 63
Date: Fri, 06 Feb 2009 14:27:29 -0500
Message-ID: <498C8F21.8000601@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020709060909080403060809"
To: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	nedev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:19182 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754045AbZBFW2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 17:28:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020709060909080403060809
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch bumps the version up to 63

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>



--------------020709060909080403060809
Content-Type: text/plain;
 name="patch-forcedeth-version-bump"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-version-bump"

--- old/drivers/net/forcedeth.c	2009-02-06 14:17:19.000000000 -0500
+++ new/drivers/net/forcedeth.c	2009-02-06 14:18:05.000000000 -0500
@@ -39,7 +39,7 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.62"
+#define FORCEDETH_VERSION		"0.63"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>

--------------020709060909080403060809--
