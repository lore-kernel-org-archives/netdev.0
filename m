From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 00/14] net: mvpp2: comphy configuration
Date: Fri, 25 Aug 2017 17:51:11 +0200
Message-ID: <20170825155111.GD30922@lunn.ch>
References: <20170825144821.31129-1-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kishon@ti.com, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170825144821.31129-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>   - Checked if the carrier_on/off functions were needed. They are.

Hi Antoine

Could you explain the situations they are needed in?

Quite a few drivers do this, so i'm not saying it is wrong.  But it
would be nice to understand if we are missing something in phylib.

      Andrew
