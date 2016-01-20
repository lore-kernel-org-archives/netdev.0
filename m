From: skallam <siva.kallam@broadcom.com>
Subject: [PATCH net-next 0/2] tg3: update on maintainer and fix for tx timeout
Date: Wed, 20 Jan 2016 17:16:56 +0530
Message-ID: <1453290418-15331-1-git-send-email-siva.kallam@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <mchan@broadcom.com>,
	<prashant@broadcom.com>,
	Siva Reddy Kallam <siva.kallam@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:10015 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933127AbcATLrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 06:47:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Siva Reddy Kallam <siva.kallam@broadcom.com>

First patch:
	This patch includes additional maintainer for tg3

Second patch:
	Fix for tg3 transmit queue 0 timed out when too many gso_segs

Siva Reddy Kallam (2):
  MAINTAINERS: Update tg3 maintainer
  tg3: Fix for tg3 transmit queue 0 timed out when too many gso_segs.

 MAINTAINERS                         |  1 +
 drivers/net/ethernet/broadcom/tg3.c | 25 +++++++++++++++++++------
 2 files changed, 20 insertions(+), 6 deletions(-)

-- 
1.9.1
