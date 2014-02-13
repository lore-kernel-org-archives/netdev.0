From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 10/10] MAINTAINERS: add entry for the Broadcom GENET driver
Date: Wed, 12 Feb 2014 21:29:55 -0800
Message-ID: <1392269395-23513-11-git-send-email-f.fainelli@gmail.com>
References: <1392269395-23513-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <cernekee@gmail.com>,
	<devicetree@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:8568 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753403AbaBMFa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 00:30:28 -0500
In-Reply-To: <1392269395-23513-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add myself as a maintainer of the Broadcom GENET driver.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes since v1:
- rebased

 MAINTAINERS | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 091b50e..5a7b3ec 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1845,6 +1845,12 @@ L:	netdev@vger.kernel.org
 S:	Supported
 F:	drivers/net/ethernet/broadcom/b44.*
 
+BROADCOM GENET ETHERNET DRIVER
+M:	Florian Fainelli <f.fainelli@gmail.com>
+L:	netdev@vger.kernel.org
+S:	Supported
+F:	drivers/net/ethernet/broadcom/genet/
+
 BROADCOM BNX2 GIGABIT ETHERNET DRIVER
 M:	Michael Chan <mchan@broadcom.com>
 L:	netdev@vger.kernel.org
-- 
1.8.3.2
