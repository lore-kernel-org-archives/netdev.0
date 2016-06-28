From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net-next 0/2] qed*: Fix the static checker warnings.
Date: Tue, 28 Jun 2016 02:10:57 -0400
Message-ID: <1467094259-16061-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:48306 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751158AbcF1Gz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 02:55:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch series addresses the static checker warnings introduced by the
earlier patches related to qed/qede coalesce configuration support.

Sudarsana Reddy Kalluru (2):
  qed: Fix static checker warnings.
  qede: Fix the static checker warnings.

 drivers/net/ethernet/qlogic/qed/qed.h           | 4 ++--
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 8 +++++---
 2 files changed, 7 insertions(+), 5 deletions(-)

-- 
1.8.3.1
