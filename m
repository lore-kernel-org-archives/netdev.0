From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/5] net: dsa: use phy_ethtool_get_link_ksettings
Date: Tue, 26 Sep 2017 23:57:34 +0200
Message-ID: <20170926215734.GL3325@lunn.ch>
References: <20170926211535.21273-1-vivien.didelot@savoirfairelinux.com>
 <20170926211535.21273-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170926211535.21273-4-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 26, 2017 at 05:15:33PM -0400, Vivien Didelot wrote:
> Use phy_ethtool_get_link_ksettings now that dsa_slave_get_link_ksettings
> does exactly the same.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
