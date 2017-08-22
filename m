From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/10] net: mvpp2: MAC/GoP configuration
Date: Tue, 22 Aug 2017 14:32:50 -0700 (PDT)
Message-ID: <20170822.143250.1510952084327060303.davem@davemloft.net>
References: <20170822170830.32413-1-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: antoine.tenart@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44546 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752275AbdHVVcw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 17:32:52 -0400
In-Reply-To: <20170822170830.32413-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Date: Tue, 22 Aug 2017 19:08:20 +0200

> This is based on net-next (e2a7c34fb285).
> 
> I removed the GoP interrupt and PHY optional parts in this v2 to ease
> the review process as the MAC/GoP initialization seemed to start less
> discussions :)
> 
> This series now only aims at making the PPv2 driver less depending on
> the firmware/bootloader initialization. Some patches cleanup some parts
> as well, and add new interface descriptions in the dt.
 ...
> @Dave: patches 9 and 10 should go through the mvebu tree. Thanks!

Patches 1-8 applied to net-next, thanks.
