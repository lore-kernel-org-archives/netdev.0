From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH net-next 0/1] net: phy: Add support for Microsemi VSC 8530/40 Fast Ethernet PHY
Date: Fri, 28 Oct 2016 12:10:10 +0200
Message-ID: <1477649411-31036-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <raju.lakkaraju@microsemi.com>,
        <allan.nielsen@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0066.outbound.protection.outlook.com ([104.47.37.66]:3768
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751913AbcJ1KKp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Oct 2016 06:10:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

This patch adds support for VSC 8530/40 which is 10/100 Mbps variants of VSC
8531/41.

Please review.

Best regards
Allan and Raju


Raju Lakkaraju (1):
  net: phy: Add support for Microsemi VSC 8530/40 Fast Ethernet PHY

 drivers/net/phy/Kconfig |  2 +-
 drivers/net/phy/mscc.c  | 42 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 1 deletion(-)

-- 
2.7.3
