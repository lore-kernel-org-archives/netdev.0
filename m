From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 05/12] net: dsa: mv88e6xxx: remove 88E6185 G2
 interrupt
Date: Mon, 17 Jul 2017 20:55:58 +0200
Message-ID: <20170717185558.GA8598@lunn.ch>
References: <20170717170346.19555-1-vivien.didelot@savoirfairelinux.com>
 <20170717170346.19555-6-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170717170346.19555-6-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 17, 2017 at 01:03:39PM -0400, Vivien Didelot wrote:
> The 88E6185 family has no Global 2 Interrupt Source or Mask registers.
> Remove the MV88E6XXX_FLAG_G2_INT from MV88E6XXX_FLAGS_FAMILY_6185.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
