From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/5] net: dsa: return -ENODEV is there is no
 slave PHY
Date: Tue, 26 Sep 2017 23:49:00 +0200
Message-ID: <20170926214900.GJ3325@lunn.ch>
References: <20170926211535.21273-1-vivien.didelot@savoirfairelinux.com>
 <20170926211535.21273-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170926211535.21273-2-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 26, 2017 at 05:15:31PM -0400, Vivien Didelot wrote:
> Instead of returning -EOPNOTSUPP when a slave device has no PHY,
> directly return -ENODEV as ethtool and phylib do.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
