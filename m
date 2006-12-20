From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH] forcedeth: modified comment header
Date: Tue, 19 Dec 2006 23:33:32 -0500
Message-ID: <4588BD1C.1010308@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030603060507000401020903"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate02.nvidia.com ([216.228.112.143]:8402 "EHLO
	HQEMGATE02.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964905AbWLTGeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Dec 2006 01:34:10 -0500
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030603060507000401020903
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch removes comment that forcedeth is not supported by NVIDIA.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------030603060507000401020903
Content-Type: text/plain;
 name="patch-forcedeth-header"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-header"

--- orig-2.6/drivers/net/forcedeth.c	2006-12-19 23:16:38.000000000 -0500
+++ new-2.6/drivers/net/forcedeth.c	2006-12-19 23:19:28.000000000 -0500
@@ -3,8 +3,7 @@
  *
  * Note: This driver is a cleanroom reimplementation based on reverse
  *      engineered documentation written by Carl-Daniel Hailfinger
- *      and Andrew de Quincey. It's neither supported nor endorsed
- *      by NVIDIA Corp. Use at your own risk.
+ *      and Andrew de Quincey.
  *
  * NVIDIA, nForce and other NVIDIA marks are trademarks or registered
  * trademarks of NVIDIA Corporation in the United States and other
@@ -14,7 +13,7 @@
  * Copyright (C) 2004 Andrew de Quincey (wol support)
  * Copyright (C) 2004 Carl-Daniel Hailfinger (invalid MAC handling, insane
  *		IRQ rate fixes, bigendian fixes, cleanups, verification)
- * Copyright (c) 2004 NVIDIA Corporation
+ * Copyright (c) 2004,5,6 NVIDIA Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by

--------------030603060507000401020903--
