From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 01/12] net: dsa: mv88e6xxx: remove unneeded dsa
 header
Date: Mon, 17 Jul 2017 20:57:56 +0200
Message-ID: <20170717185756.GE8598@lunn.ch>
References: <20170717170346.19555-1-vivien.didelot@savoirfairelinux.com>
 <20170717170346.19555-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170717170346.19555-2-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 17, 2017 at 01:03:35PM -0400, Vivien Didelot wrote:
> phy.c does not need to include the DSA public header. Remove it.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Signed-off-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
