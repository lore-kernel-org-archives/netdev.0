From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v5 3/7] net: phy: broadcom: Add BCM54810 PHY entry
Date: Wed, 2 Nov 2016 19:37:14 +0100
Message-ID: <20161102183714.GH384@lunn.ch>
References: <1478106488-11779-1-git-send-email-jon.mason@broadcom.com>
 <1478106488-11779-4-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com, rafal@milecki.pl,
        linux-arm-kernel@lists.infradead.org
To: Jon Mason <jon.mason@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34638 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932385AbcKBShV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Nov 2016 14:37:21 -0400
Content-Disposition: inline
In-Reply-To: <1478106488-11779-4-git-send-email-jon.mason@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 02, 2016 at 01:08:04PM -0400, Jon Mason wrote:
> The BCM54810 PHY requires some semi-unique configuration, which results
> in some additional configuration in addition to the standard config.
> Also, some users of the BCM54810 require the PHY lanes to be swapped.
> Since there is no way to detect this, add a device tree query to see if
> it is applicable.
> 
> Inspired-by: Vikas Soni <vsoni@broadcom.com>
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
