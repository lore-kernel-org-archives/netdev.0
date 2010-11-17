From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next 3/5] qlcnic: Add description for CN1000Q adapter
Date: Tue, 16 Nov 2010 16:08:23 -0800
Message-ID: <alpine.OSX.2.00.1011161520130.88679@macintosh-2.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:19279 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757143Ab0KQAI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 19:08:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

Add description for CN1000Q adapter

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index a6b71fe..1375981 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -1376,6 +1376,8 @@ static const struct qlcnic_brdinfo qlcnic_boards[] = {
 		"3200 Series Single Port 10Gb Intelligent Ethernet Adapter"},
 	{0x1077, 0x8020, 0x103c, 0x3733,
 		"NC523SFP 10Gb 2-port Server Adapter"},
+	{0x1077, 0x8020, 0x103c, 0x3346,
+		"CN1000Q Dual Port Converged Network Adapter"},
 	{0x1077, 0x8020, 0x0, 0x0, "cLOM8214 1/10GbE Controller"},
 };
 
-- 
1.5.4.5

