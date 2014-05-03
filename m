From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: systemport: couple fixes
Date: Sat,  3 May 2014 11:31:12 -0700
Message-ID: <1399141874-12003-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35551 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193AbaECSbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2014 14:31:32 -0400
Received: by mail-pa0-f41.google.com with SMTP id lj1so4494527pab.0
        for <netdev@vger.kernel.org>; Sat, 03 May 2014 11:31:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series contains two small fixes for the Broadcom SYSTEMPORT driver.

Thank you!

Florian Fainelli (2):
  net: systemport: only update UMAC_CMD if something changed
  net: systemport: pad packets to a minimum of 64 bytes

 drivers/net/ethernet/broadcom/bcmsysport.c | 29 +++++++++++++++++++----------
 1 file changed, 19 insertions(+), 10 deletions(-)

-- 
1.9.1
