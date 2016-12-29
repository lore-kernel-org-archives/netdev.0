From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 14/14] MAINTAINERS: Add bnxt_en maintainer info.
Date: Thu, 29 Dec 2016 12:13:44 -0500
Message-ID: <1483031624-20076-15-git-send-email-michael.chan@broadcom.com>
References: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:35455 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753337AbcL2RON (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 12:14:13 -0500
Received: by mail-pg0-f42.google.com with SMTP id i5so103582221pgh.2
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2016 09:14:12 -0800 (PST)
In-Reply-To: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 MAINTAINERS | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index cfff2c9..11904a9 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2605,6 +2605,12 @@ L:	netdev@vger.kernel.org
 S:	Supported
 F:	drivers/net/ethernet/broadcom/bnx2x/
 
+BROADCOM BNXT_EN 50 GIGABIT ETHERNET DRIVER
+M:	Michael Chan <michael.chan@broadcom.com>
+L:	netdev@vger.kernel.org
+S:	Supported
+F:	drivers/net/ethernet/broadcom/bnxt/
+
 BROADCOM BCM281XX/BCM11XXX/BCM216XX ARM ARCHITECTURE
 M:	Florian Fainelli <f.fainelli@gmail.com>
 M:	Ray Jui <rjui@broadcom.com>
-- 
1.8.3.1
