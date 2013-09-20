From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 0/8] tg3: Misc cleanups and fixes.
Date: Fri, 20 Sep 2013 16:46:54 -0700
Message-ID: <1379720822-6500-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4365 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752036Ab3ITXr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Sep 2013 19:47:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nithin Nayak Sujir (8):
  tg3: Add function tg3_phy_shdw_write()
  tg3: Add support for new 577xx device ids
  tg3: LED in shared mode does not blink during traffic
  tg3: Remove if 0'd code
  tg3: Remove redundant if check
  tg3: Appropriately classify interrupts during request_irq
  tg3: Remove unnecessary spinlock
  tg3: Update version to 3.134

 drivers/net/ethernet/broadcom/tg3.c | 81 ++++++++++++++++++++-----------------
 drivers/net/ethernet/broadcom/tg3.h |  3 ++
 2 files changed, 47 insertions(+), 37 deletions(-)

-- 
1.8.1.4
