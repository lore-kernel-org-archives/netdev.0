From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 13/13] forcedeth: version bump to 64
Date: Thu, 05 Mar 2009 13:02:38 -0500
Message-ID: <49B013BE.4030101@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010907080605020809090303"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:1629 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755870AbZCEVCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 16:02:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010907080605020809090303
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch bumps up the version to 0.64

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

--------------010907080605020809090303
Content-Type: text/plain;
 name="patch-forcedeth-version-64"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-version-64"

--- old/drivers/net/forcedeth.c	2009-03-05 10:48:03.000000000 -0800
+++ new/drivers/net/forcedeth.c	2009-03-05 10:48:14.000000000 -0800
@@ -39,7 +39,7 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.63"
+#define FORCEDETH_VERSION		"0.64"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>

--------------010907080605020809090303--
