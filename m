From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 06/12] net: dsa: mv88e6xxx: add number of Global
 2 IRQs
Date: Mon, 17 Jul 2017 19:43:57 +0200
Message-ID: <20170717174357.GI30392@lunn.ch>
References: <20170717170346.19555-1-vivien.didelot@savoirfairelinux.com>
 <20170717170346.19555-7-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170717170346.19555-7-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 17, 2017 at 01:03:40PM -0400, Vivien Didelot wrote:
> Similarly to g1_irqs, add a g2_irqs member to the info structure to
> indicates the presence of the Global 2 Interrupt Source and Mask
> registers.
> 
> At the same time, provide helpers and document the registers since they
> differ a bit between 88E6352 and 88E6390 families.
> 
> This allows us to get rid of the MV88E6XXX_FLAG_G2_INT flag.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
