From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: phy: bcm7xxx: workaround updates
Date: Fri, 14 Mar 2014 16:09:03 -0700
Message-ID: <1394838545-7746-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:39223 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754470AbaCNXJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 19:09:17 -0400
Received: by mail-ig0-f174.google.com with SMTP id h18so451276igc.1
        for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 16:09:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patchset contains two small workaround updates for the Broadcom
BCM7xxx internal PHY driver.

Thanks!

Florian Fainelli (2):
  net: phy: bcm7xxx: fix spurious MDIO failures during workaround
  net: phy: bcm7xxx: properly clear AFE_RX_LP_COUNTER

 drivers/net/phy/bcm7xxx.c | 31 ++++++++++++++++---------------
 1 file changed, 16 insertions(+), 15 deletions(-)

-- 
1.8.3.2
