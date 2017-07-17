From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 12/12] net: dsa: mv88e6xxx: add a multi_chip
 info flag
Date: Mon, 17 Jul 2017 21:32:19 +0200
Message-ID: <20170717193219.GE9363@lunn.ch>
References: <20170717170346.19555-1-vivien.didelot@savoirfairelinux.com>
 <20170717170346.19555-13-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170717170346.19555-13-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 17, 2017 at 01:03:46PM -0400, Vivien Didelot wrote:
> Instead of relying on a bitmap flag, add a new multi_chip info flag to
> describe the presence of the indirect SMI access though the two device
> registers 0x0 and 0x1.
> 
> All remaining capabilities and flags are now unused. Remove the
> mv88e6xxx_cap enum and the info flags bitmaps.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
