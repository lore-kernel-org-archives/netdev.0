From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 6/6] qlcnic: remove extra space from board names
Date: Mon,  8 Mar 2010 02:14:50 -0800
Message-ID: <1268043290-19929-7-git-send-email-amit.salecha@qlogic.com>
References: <1268043290-19929-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com,
	ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:29746 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753434Ab0CHKOx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Mar 2010 05:14:53 -0500
In-Reply-To: <1268043290-19929-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 9897b69..0da94b2 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -1100,11 +1100,11 @@ struct qlcnic_brdinfo {
 
 static const struct qlcnic_brdinfo qlcnic_boards[] = {
 	{0x1077, 0x8020, 0x1077, 0x203,
-		"8200 Series Single Port 10GbE Converged Network Adapter \
-		(TCP/IP Networking)"},
+		"8200 Series Single Port 10GbE Converged Network Adapter "
+		"(TCP/IP Networking)"},
 	{0x1077, 0x8020, 0x1077, 0x207,
-		"8200 Series Dual Port 10GbE Converged Network Adapter \
-		(TCP/IP Networking)"},
+		"8200 Series Dual Port 10GbE Converged Network Adapter "
+		"(TCP/IP Networking)"},
 	{0x1077, 0x8020, 0x1077, 0x20b,
 		"3200 Series Dual Port 10Gb Intelligent Ethernet Adapter"},
 	{0x1077, 0x8020, 0x1077, 0x20c,
-- 
1.6.0.2

