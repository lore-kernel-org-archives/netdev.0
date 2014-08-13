From: Harish Patil <harish.patil@qlogic.com>
Subject: [PATCH net-next 0/2] qlge: Fix compilation warning and update maintainers
Date: Wed, 13 Aug 2014 14:08:07 -0400
Message-ID: <1407953289-23460-1-git-send-email-harish.patil@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>,
	Harish Patil <harish.patil@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:41831 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752890AbaHMSkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 14:40:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harish Patil <harish.patil@qlogic.com>

This patch series includes the following set of patches:

- Fix the below warning message observed during qlge compilation:
  qlge_main.c:1754: warning: 'lbq_desc' may be used uninitialized in this function

- Update qlge driver maintainers list

Please apply this series to net-next.

Thanks,
Harish

Harish Patil (1):
   qlge: Fix compilation warning
   Update qlge driver maintainers list

MAINTAINERS                                  | 4 ++--
drivers/net/ethernet/qlogic/qlge/qlge_main.c | 4 ++--
2 files changed, 4 insertions(+), 4 deletions(-)
