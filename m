From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 07/18] net: mvpp2: initialize the GoP
Date: Wed, 26 Jul 2017 18:16:17 +0200
Message-ID: <20170726161617.GI12049@lunn.ch>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-8-antoine.tenart@free-electrons.com>
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
Received: from vps0.lunn.ch ([178.209.37.122]:40989 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750893AbdGZQQW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 12:16:22 -0400
Content-Disposition: inline
In-Reply-To: <20170724134848.19330-8-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +	switch (port->phy_interface) {
> +	case PHY_INTERFACE_MODE_RGMII:

Here as well,

     Andrew
