From: Nilesh Javali <nilesh.javali@qlogic.com>
Subject: [PATCH net 0/1] cnic: Update the rcu_access_pointer() usages
Date: Tue, 28 Oct 2014 01:18:14 -0400
Message-ID: <1414473495-24790-1-git-send-email-nilesh.javali@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>, <vikas.chaudhary@qlogic.com>,
	<giridhar.malavali@qlogic.com>, <tej.parkash@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:36408 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757459AbaJ1Fxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 01:53:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the rcu_access_pointer usages:

Tej Parkash (1):
      cnic: Update the rcu_access_pointer() usages

 drivers/net/ethernet/broadcom/cnic.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

Please apply this patch to net.

Thanks,
Nilesh
