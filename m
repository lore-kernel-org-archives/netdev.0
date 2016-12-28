From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv2 net-next 08/11] net: mvpp2: fix indentation of MVPP2_EXT_GLOBAL_CTRL_DEFAULT
Date: Wed, 28 Dec 2016 17:46:04 +0100
Message-ID: <1482943567-12483-9-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1482943567-12483-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        linux-arm-kernel@lists.infradead.org,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47562 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751849AbcL1QqZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 11:46:25 -0500
In-Reply-To: <1482943567-12483-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index edffcc1..36c73dc 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -254,7 +254,7 @@
 #define MVPP2_PHY_AN_CFG0_REG			0x34
 #define     MVPP2_PHY_AN_STOP_SMI0_MASK		BIT(7)
 #define MVPP2_MNG_EXTENDED_GLOBAL_CTRL_REG	0x305c
-#define MVPP2_EXT_GLOBAL_CTRL_DEFAULT		0x27
+#define     MVPP2_EXT_GLOBAL_CTRL_DEFAULT	0x27
 
 /* Per-port registers */
 #define MVPP2_GMAC_CTRL_0_REG			0x0
-- 
2.7.4
