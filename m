From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: mvpp2: software TSO support
Date: Wed, 23 Aug 2017 20:42:25 -0700 (PDT)
Message-ID: <20170823.204225.1855898046144610241.davem@davemloft.net>
References: <20170823074656.14595-1-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org
To: antoine.tenart@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58310 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751019AbdHXDm2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 23:42:28 -0400
In-Reply-To: <20170823074656.14595-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Date: Wed, 23 Aug 2017 09:46:53 +0200

> This series adds the s/w TSO support in the PPv2 driver, in addition to
> two cosmetic commits. As stated in patch 3/3:
> 
> Using iperf and 10G ports, using TSO shows a significant performance
> improvement by a factor 2 to reach around 9.5Gbps in TX; as well as a
> significant CPU usage drop (from 25% to 15%).

Series applied, thank you.
