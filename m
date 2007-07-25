From: dhananjay@netxen.com
Subject: [RESEND 0/2] netxen: bug fixes for IMEZ adapters on pblades
Date: Wed, 25 Jul 2007 20:13:10 +0530
Message-ID: <20070725144310.500691352@netxen.com>
Cc: rob@netxen.com, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.199.144.227] ([203.199.144.227]:1028 "EHLO
	stellar.unminc.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760231AbXGYOv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 10:51:27 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Resending the earlier patches, since the old patch got committed. 

 drivers/net/netxen/netxen_nic_main.c |   40 +++++++++++++++++----------------
 1 files changed, 21 insertions(+), 19 deletions(-)

