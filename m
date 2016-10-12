From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH net-next v11 0/1] net: phy: Rebase Edge-Rate clean up
Date: Wed, 12 Oct 2016 15:47:50 +0200
Message-ID: <1476280071-6886-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0055.outbound.protection.outlook.com ([104.47.32.55]:7136
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932373AbcJLQWo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Oct 2016 12:22:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I can see that the "Add Wake-on-LAN driver for Microsemi PHYs" (0a55c12f97)
patch has been applied to net-next, and that it is causing the Edge-Rate patch
to conflict.

I have therefore rebased v10 of the patch to fit on top of net-next.

/Allan

-- 
2.7.3
