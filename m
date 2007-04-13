From: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 4/7] NetXen: Removal of redundant macros
Date: Fri, 13 Apr 2007 08:41:01 -0700
Message-ID: <200704131541.l3DFf1c9002605@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, mithlesh@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:17095 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754057AbXDMPlC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2007 11:41:02 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Remove 2 redundant macro definitions from header file.

Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>

---

 drivers/net/netxen/netxen_nic_phan_reg.h |    2 --
 1 files changed, 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
index cb9acf1..12bcaf9 100644
--- a/drivers/net/netxen/netxen_nic_phan_reg.h
+++ b/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -100,8 +100,6 @@ #define CRB_JUMBO_BUFFER_CONS       NETX
 
 #define CRB_CMD_PRODUCER_OFFSET_1   NETXEN_NIC_REG(0x1ac)
 #define CRB_CMD_CONSUMER_OFFSET_1   NETXEN_NIC_REG(0x1b0)
-#define CRB_CMD_PRODUCER_OFFSET_1   NETXEN_NIC_REG(0x1ac)
-#define CRB_CMD_CONSUMER_OFFSET_1   NETXEN_NIC_REG(0x1b0)
 #define CRB_CMD_PRODUCER_OFFSET_2   NETXEN_NIC_REG(0x1b8)
 #define CRB_CMD_CONSUMER_OFFSET_2   NETXEN_NIC_REG(0x1bc)
 
