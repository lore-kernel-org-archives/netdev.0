From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 4/7] qlcnic: fix board description
Date: Fri,  8 Oct 2010 02:46:08 -0700
Message-ID: <1286531171-21173-5-git-send-email-amit.salecha@qlogic.com>
References: <1286531171-21173-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:11375 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754731Ab0JHJqM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Oct 2010 05:46:12 -0400
In-Reply-To: <1286531171-21173-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

Remove "Flex-10" from board description.

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 6909cfc..46a54b3 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -1370,7 +1370,7 @@ static const struct qlcnic_brdinfo qlcnic_boards[] = {
 	{0x1077, 0x8020, 0x1077, 0x20f,
 		"3200 Series Single Port 10Gb Intelligent Ethernet Adapter"},
 	{0x1077, 0x8020, 0x103c, 0x3733,
-		"NC523SFP 10Gb 2-port Flex-10 Server Adapter"},
+		"NC523SFP 10Gb 2-port Server Adapter"},
 	{0x1077, 0x8020, 0x0, 0x0, "cLOM8214 1/10GbE Controller"},
 };
 
-- 
1.6.0.2

