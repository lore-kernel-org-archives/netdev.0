From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 0/6] tg3: Misc cleanups and refactoring
Date: Thu, 23 May 2013 14:11:21 -0700
Message-ID: <1369343487-6453-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1190 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758979Ab3EWVLm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 17:11:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nithin Nayak Sujir (6):
  tg3: Split APE driver state change out of boot reset signature update
  tg3: Simplify ring control block setup
  tg3: Make tg3_rings_reset() more concise
  tg3: Use descriptive label names in tg3_start
  tg3: Fix misplaced empty line
  tg3: Remove unnecessary lock around tg3_flag_set

 drivers/net/ethernet/broadcom/tg3.c | 150 +++++++++++++++++++++---------------
 1 file changed, 88 insertions(+), 62 deletions(-)

-- 
1.8.1.4
