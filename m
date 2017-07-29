From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] MAINTAINERS: Include platform_data/mdio-gpio.h into
 PHY LIBRARY
Date: Sat, 29 Jul 2017 02:21:19 +0200
Message-ID: <20170729002119.GD16080@lunn.ch>
References: <20170728230812.29941-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44483 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752987AbdG2AVX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Jul 2017 20:21:23 -0400
Content-Disposition: inline
In-Reply-To: <20170728230812.29941-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 28, 2017 at 04:08:12PM -0700, Florian Fainelli wrote:
> Include the file include/linux/platform_data/mdio-gpio.h into the PHY
> LIBRARY maintainers section.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  MAINTAINERS | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 297e610c9163..7b5834ee1260 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -5140,6 +5140,7 @@ L:	netdev@vger.kernel.org
>  S:	Maintained
>  F:	include/linux/phy.h
>  F:	include/linux/phy_fixed.h
> +F:	include/linux/platform_data/mdio-gpio.h
>  F:	drivers/net/phy/
>  F:	Documentation/networking/phy.txt
>  F:	drivers/of/of_mdio.c

Hi Florian

There are a few more which you might consider adding:

include/uapi/linux/mdio.h
include/trace/events/mdio.h
include/linux/mdio-bitbang.h
include/linux/mdio-mux.h
include/linux/of_mdio.h
include/linux/platform_data/mdio-gpio.h
include/linux/mdio.h

	Andrew
