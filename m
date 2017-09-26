From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/5] net: dsa: use slave device phydev
Date: Tue, 26 Sep 2017 23:56:14 +0200
Message-ID: <20170926215614.GK3325@lunn.ch>
References: <20170926211535.21273-1-vivien.didelot@savoirfairelinux.com>
 <20170926211535.21273-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170926211535.21273-3-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 26, 2017 at 05:15:32PM -0400, Vivien Didelot wrote:
> There is no need to store a phy_device in dsa_slave_priv since
> net_device already provides one. Simply s/p->phy/dev->phydev/.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
