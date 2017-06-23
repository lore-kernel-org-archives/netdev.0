From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net: phy: Support "internal" PHY interface
Date: Fri, 23 Jun 2017 15:07:05 -0400 (EDT)
Message-ID: <20170623.150705.237882810208849414.davem@davemloft.net>
References: <20170623173316.23017-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robh+dt@kernel.org, mark.rutland@arm.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        sean.wang@mediatek.com, martin.blumenstingl@googlemail.com,
        rmk+kernel@armlinux.org.uk, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, david.wu@rock-chips.com,
        opendmb@gmail.com
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170623173316.23017-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 23 Jun 2017 10:33:12 -0700

> This makes the "internal" phy-mode property generally available and
> documented and this allows us to remove some custom parsing code
> we had for bcmgenet and bcm_sf2 which both used that specific value.

Nice cleanup.

Series applied, thanks.
