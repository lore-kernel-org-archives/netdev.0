From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/3] net: mvpp2: improve the mac address
 retrieval logic
Date: Sun, 03 Sep 2017 20:17:12 -0700 (PDT)
Message-ID: <20170903.201712.965418842136022662.davem@davemloft.net>
References: <20170902090649.28426-1-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org
To: antoine.tenart@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170902090649.28426-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Date: Sat,  2 Sep 2017 11:06:46 +0200

> This series aims at fixing the logic behind the MAC address retrieval in the
> PPv2 driver. A possible issue is also fixed in patch 3/3 to introduce fallbacks
> when the address given in the device tree isn't valid.
 ...
> Since v2:
>   - Patch 1/4 from v2 was applied on net (and net was merged in net-next).
>   - Rebased on net-next.
> 
> Since v1:
>   - Rebased onto net (was on net-next).

Series applied, thank you.
