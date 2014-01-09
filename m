From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 0/2] qlcnic: Bug fixes
Date: Thu, 9 Jan 2014 12:41:03 -0500
Message-ID: <1389289265-9586-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:37489 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756400AbaAISOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 13:14:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Hi David,

This patch series has couple of bug fixes related to statistics.

Please apply this series to net.

Thanks,
Shahed

Manish Chopra (1):
  qlcnic: Fix bug in TX statistics

Shahed Shaikh (1):
  qlcnic: Fix ethtool statistics length calculation

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    | 41 ++++++++++++----------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  3 ++
 3 files changed, 26 insertions(+), 19 deletions(-)

-- 
1.8.1.4
