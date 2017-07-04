From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 0/2] net: phy: dp83867: workaround incorrect RX_CTRL pin
 strap
Date: Tue, 4 Jul 2017 16:47:52 +0200
Message-ID: <20170704144752.GB10312@lunn.ch>
References: <cover.1499162046.git.nsekhar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Device Tree Mailing List <devicetree@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Tony Lindgren <tony@atomide.com>,
        Linux OMAP Mailing List <linux-omap@vger.kernel.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: Sekhar Nori <nsekhar@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45004 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752127AbdGDOsD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Jul 2017 10:48:03 -0400
Content-Disposition: inline
In-Reply-To: <cover.1499162046.git.nsekhar@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 04, 2017 at 04:23:22PM +0530, Sekhar Nori wrote:
> Hi,
> 
> This patch series adds workaround for incorrect RX_CTRL pin strap
> setting that can be found on some TI boards.

Hi Sekhar

Do you plan to post some DT patches to make use of this? It would be
good to seem them as well.

     Thanks
	Andrew
