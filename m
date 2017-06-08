From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 7/7] net: dsa: mv88e6xxx: prefix PHY macros
Date: Thu, 8 Jun 2017 21:43:07 +0200
Message-ID: <20170608194307.GK20216@lunn.ch>
References: <20170608190445.24443-1-vivien.didelot@savoirfairelinux.com>
 <20170608190445.24443-8-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170608190445.24443-8-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 08, 2017 at 03:04:45PM -0400, Vivien Didelot wrote:
> Prefix the PHY_* macros with a Marvell specific MV88E6XXX_ prefix.
> There is no functional changes.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
