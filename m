From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net 0/4] qlcnic: bug fixes
Date: Fri, 26 Jul 2013 16:23:59 -0400
Message-ID: <cover.1374891091.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:52902 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760623Ab3GZVYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 17:24:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

Please apply to net.

Thanks,
Himanshu

Jitendra Kalsaria (1):
  qlcnic: Fix initialization of work function.

Manish Chopra (2):
  qlcnic: Fix setting Guest VLAN
  qlcnic: Fix diagnostic interrupt test for 83xx adapters.

Pratik Pujar (1):
  qlcnic: Fix operation type and command type.

 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |  4 +--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  2 ++
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |  2 ++
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   | 30 +++++++++++++++++++---
 4 files changed, 32 insertions(+), 6 deletions(-)

-- 
1.8.1.4
