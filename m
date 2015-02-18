From: Rasesh Mody <rasesh.mody@qlogic.com>
Subject: [net-next 0/3] bnx2-cnic: Driver Version Upgrades
Date: Tue, 17 Feb 2015 19:26:17 -0500
Message-ID: <1424219180-29028-1-git-send-email-rasesh.mody@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Dept-HSGLinuxNICDev@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rasesh Mody <rasesh.mody@qlogic.com>
To: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:55638 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751903AbbBRBF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 20:05:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch set includes bnx2 and cnic drivers' re-branding changes, fix for a
chip initialization issue and updates the bnx2 driver version to 2.2.6 and
cnic driver version to 2.5.21.

Please apply these patches to net-next.

Thanks,
Rasesh

Rasesh Mody (3):
  bnx2-cnic: Driver Rebranding Changes
  bnx2: Fix for Chip Initialization
  bnx2-cnic: Driver Version Update

 drivers/net/ethernet/broadcom/Kconfig   |  8 ++++----
 drivers/net/ethernet/broadcom/bnx2.c    | 14 ++++++--------
 drivers/net/ethernet/broadcom/bnx2.h    |  4 ++--
 drivers/net/ethernet/broadcom/bnx2_fw.h |  4 ++--
 drivers/net/ethernet/broadcom/cnic.c    |  6 +++---
 drivers/net/ethernet/broadcom/cnic_if.h |  8 ++++----
 6 files changed, 21 insertions(+), 23 deletions(-)

-- 
1.8.2.3
