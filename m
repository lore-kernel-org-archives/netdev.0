From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 08/12] net: dsa: mv88e6xxx: add POT flag to
 88E6390
Date: Mon, 17 Jul 2017 21:15:16 +0200
Message-ID: <20170717191516.GA9363@lunn.ch>
References: <20170717170346.19555-1-vivien.didelot@savoirfairelinux.com>
 <20170717170346.19555-9-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170717170346.19555-9-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 17, 2017 at 01:03:42PM -0400, Vivien Didelot wrote:
> The 88E6390 family clear the Priority Override Table the same way as
> 88E6352, thus add MV88E6XXX_FLAG_G2_POT to MV88E6XXX_FLAGS_FAMILY_6390.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
