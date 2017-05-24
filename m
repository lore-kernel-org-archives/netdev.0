From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/3] net: sysfs: Document PHY device sysfs
 attributes
Date: Wed, 24 May 2017 22:10:18 +0200
Message-ID: <20170524201018.GH1788@lunn.ch>
References: <20170524193354.10739-1-f.fainelli@gmail.com>
 <20170524193354.10739-4-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43653 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754593AbdEXUKW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 May 2017 16:10:22 -0400
Content-Disposition: inline
In-Reply-To: <20170524193354.10739-4-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +What:		/sys/class/mdio_bus/<bus>/<device>/phy_interface
> +Date:		February 2014
> +KernelVersion:	3.15
> +Contact:	netdev@vger.kernel.org
> +Description:
> +		String value indicating the PHY interface, possible
> +		values are in include/linux/phy.h function phy_modes.

Hi Florian

Does this suggest that these strings should be moved to
include/uapi/linux/phy.h?

	Andrew
