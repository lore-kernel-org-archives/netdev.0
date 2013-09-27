From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 0/2] netxen_nic: Minor enhancement
Date: Fri, 27 Sep 2013 01:42:25 -0400
Message-ID: <1380260547-25903-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:45776 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751119Ab3I0GMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 02:12:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

This patch series contains following changes
* Log a message about ULA adapter type.
* Update the driver version to 4.0.82.

Please apply to net-next.

Thanks,
Shahed

Shahed Shaikh (2):
  netxen_nic: Print ULA information
  netxen_nic: Update version to 4.0.82

 drivers/net/ethernet/qlogic/netxen/netxen_nic.h    |    4 +-
 .../net/ethernet/qlogic/netxen/netxen_nic_hdr.h    |    1 +
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |   28 ++++++++++++++++++++
 3 files changed, 31 insertions(+), 2 deletions(-)
