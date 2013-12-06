From: Nithin Nayak Sujir <nsujir@broadcom.com>
Subject: [PATCH net-next 0/5] tg3: Misc fixes
Date: Fri, 6 Dec 2013 09:53:15 -0800
Message-ID: <1386352400-9623-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Nithin Nayak Sujir <nsujir@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:60849 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758257Ab3LFRxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 12:53:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Nithin Nayak Sujir (5):
  tg3: Don't add rxbds_empty to rx_over_errors
  tg3: Add flag to disable 1G Half Duplex advertisement
  tg3: Fix bit definition for the nvram Auto Power Down setting
  tg3: Expand multicast drop counter miscounting fix to 5762
  tg3: Update version to 3.135

 drivers/net/ethernet/broadcom/tg3.c | 37 ++++++++++++++++++++++++++-----------
 drivers/net/ethernet/broadcom/tg3.h |  6 +++++-
 2 files changed, 31 insertions(+), 12 deletions(-)

-- 
1.8.1.4
