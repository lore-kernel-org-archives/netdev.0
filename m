From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH net 0/3] qlcnic: bug fixes
Date: Thu, 15 Aug 2013 08:29:26 -0400
Message-ID: <1376569769-625-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:30000 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753473Ab3HONFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 09:05:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply to net.

Thanks,
Sucheta.

Himanshu Madhani (1):
  qlcnic: Fix set driver version command

Manish Chopra (1):
  qlcnic: Fix diagnostic interrupt test for 83xx adapters

Sucheta Chakraborty (1):
  qlcnic: Fix beacon state return status handling

 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c   | 5 +++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c | 3 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c      | 6 ++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c     | 6 +++---
 4 files changed, 14 insertions(+), 6 deletions(-)
