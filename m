From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 10/12] net: dsa: mv88e6xxx: add a global2_addr
 info flag
Date: Mon, 17 Jul 2017 21:19:41 +0200
Message-ID: <20170717191941.GC9363@lunn.ch>
References: <20170717170346.19555-1-vivien.didelot@savoirfairelinux.com>
 <20170717170346.19555-11-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170717170346.19555-11-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 17, 2017 at 01:03:44PM -0400, Vivien Didelot wrote:
> Similarly to global1_addr, add a global2_addr member in the info
> structure to describe the presence of the Global 2 Registers.
> 
> This allows us to get rid of the MV88E6XXX_FLAG_GLOBAL2 flag.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
