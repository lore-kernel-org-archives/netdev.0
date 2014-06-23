From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 0/3] Rebranding changes for bnx2 and cnic driver
Date: Mon, 23 Jun 2014 15:10:32 -0400
Message-ID: <1403550635-19700-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <sony.chacko@qlogic.com>,
	<Dept-HSGLinuxNICDev@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:59250 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756725AbaFWTlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 15:41:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

The following set of patches are for rebranding Broadcom bnx2 and cnic driver as QLogic drivers.
Please apply this series to net-next.

Jitendra Kalsaria (3):
  bnx2: Rebranding bnx2 driver.
  cnic: Rebranding cnic driver.
  MAINTAINERS: Update bnx2 maintainers

 MAINTAINERS                               |    3 ++-
 drivers/net/ethernet/broadcom/Kconfig     |    8 ++++----
 drivers/net/ethernet/broadcom/bnx2.c      |    9 +++++----
 drivers/net/ethernet/broadcom/bnx2.h      |    5 +++--
 drivers/net/ethernet/broadcom/bnx2_fw.h   |    3 ++-
 drivers/net/ethernet/broadcom/cnic.c      |   10 ++++++----
 drivers/net/ethernet/broadcom/cnic.h      |    3 ++-
 drivers/net/ethernet/broadcom/cnic_defs.h |    3 ++-
 drivers/net/ethernet/broadcom/cnic_if.h   |    3 ++-
 9 files changed, 28 insertions(+), 19 deletions(-)

-- 
1.7.9.5
