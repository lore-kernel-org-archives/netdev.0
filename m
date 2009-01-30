From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 5/5] forcedeth: bump version to 63
Date: Fri, 30 Jan 2009 13:56:43 -0500
Message-ID: <49834D6B.6020603@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000809040400080605030403"
To: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	nedev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:15718 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755932AbZA3WCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 17:02:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000809040400080605030403
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch bumps the version up to 63

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------000809040400080605030403
Content-Type: text/plain;
 name="patch-forcedeth-version-bump"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-version-bump"

--- old/drivers/net/forcedeth.c	2009-01-30 13:51:21.000000000 -0500
+++ new/drivers/net/forcedeth.c	2009-01-30 13:52:05.000000000 -0500
@@ -39,7 +39,7 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.62"
+#define FORCEDETH_VERSION		"0.63"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>

--------------000809040400080605030403--
