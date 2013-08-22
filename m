From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 0/2] qlge: feature update
Date: Thu, 22 Aug 2013 15:54:10 -0400
Message-ID: <1377201252-9283-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <ron.mercer@qlogic.com>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:29878 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753274Ab3HVUeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 16:34:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

This patch series enhance the handling of nested vlan tags in Rx path.

Please apply it to net-next.

Jitendra Kalsaria (2):
  qlge: Enhance nested VLAN (Q-in-Q) handling.
  qlge: Update version to 1.0.0.33

 drivers/net/ethernet/qlogic/qlge/qlge.h      |    2 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |   87 ++++++++++++++++++++------
 2 files changed, 68 insertions(+), 21 deletions(-)
