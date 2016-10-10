From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH net-next v10 0/1] net: phy: Cleanup the Edge-Rate feature in Microsemi PHYs.
Date: Mon, 10 Oct 2016 16:13:44 +0200
Message-ID: <1476108825-14613-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0057.outbound.protection.outlook.com ([104.47.36.57]:2048
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752433AbcJJOa3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Oct 2016 10:30:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

Yet another iteration on the edge rate.

Included in this iteration:
- vdd and slowdown is removed from private structure
- rate_magic added to private structure
- devicetree settings is read and validated in probe instead of init
- unused reference in device-tree doc removed

Please review

/Allan
