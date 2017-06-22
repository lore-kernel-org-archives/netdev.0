From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH net-next 0/3] net: mvpp2: misc improvements
Date: Thu, 22 Jun 2017 14:23:17 +0200
Message-ID: <20170622122320.32676-1-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        =?UTF-8?q?Miqu=C3=A8l=20Raynal?= <miquel.raynal@free-electrons.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:38149 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750847AbdFVMXi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 08:23:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Here are a few patches making various small improvements/refactoring
in the mvpp2 driver. They are based on today's net-next.

Thanks!

Thomas

Thomas Petazzoni (3):
  net: mvpp2: add comments about smp_processor_id() usage
  net: mvpp2: remove unused mvpp2_bm_cookie_pool_set() function
  net: mvpp2: remove mvpp2_pool_refill()

 drivers/net/ethernet/marvell/mvpp2.c | 58 ++++++++++++++++++++----------------
 1 file changed, 32 insertions(+), 26 deletions(-)

-- 
2.9.4
