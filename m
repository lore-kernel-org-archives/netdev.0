From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH V3 net-next 5/5] amd-xgbe: Maintainer information
Date: Thu, 5 Jun 2014 09:15:24 -0500
Message-ID: <20140605141524.19317.19985.stgit@tlendack-t1.amdoffice.net>
References: <20140605141454.19317.87165.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <jcm@redhat.com>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0207.outbound.protection.outlook.com ([207.46.163.207]:9337
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751848AbaFEOPo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 10:15:44 -0400
In-Reply-To: <20140605141454.19317.87165.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the maintainer information for the AMD 10GbE
platform driver.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 MAINTAINERS |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 7510623..0ee21d7 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -597,6 +597,13 @@ L:	amd64-microcode@amd64.org
 S:	Maintained
 F:	arch/x86/kernel/microcode_amd.c
 
+AMD XGBE DRIVER
+M:	Tom Lendacky <thomas.lendacky@amd.com>
+L:	netdev@vger.kernel.org
+S:	Supported
+F:	drivers/net/ethernet/amd/xgbe/
+F:	drivers/net/phy/amd-xgbe-phy.c
+
 AMS (Apple Motion Sensor) DRIVER
 M:	Michael Hanselmann <linux-kernel@hansmi.ch>
 S:	Supported
