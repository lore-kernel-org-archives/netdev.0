From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 00/10] net: mvpp2: MAC/GoP configuration
Date: Tue, 22 Aug 2017 20:07:57 +0200
Message-ID: <20170822180757.GD18076@lunn.ch>
References: <20170822170830.32413-1-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jason@lakedaemon.net,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39779 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751781AbdHVSII (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Aug 2017 14:08:08 -0400
Content-Disposition: inline
In-Reply-To: <20170822170830.32413-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 22, 2017 at 07:08:20PM +0200, Antoine Tenart wrote:
> Hi all,
> 
> This is based on net-next (e2a7c34fb285).
> 
> I removed the GoP interrupt and PHY optional parts in this v2 to ease
> the review process as the MAC/GoP initialization seemed to start less
> discussions :)

Hi Antoine

By that, do you mean setting the SMI PHY address?

   Andrew
