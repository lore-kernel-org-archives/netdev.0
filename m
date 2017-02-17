From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 1/6] net: dsa: mv88e6xxx: add port mask helper
Date: Fri, 17 Feb 2017 22:26:10 +0100
Message-ID: <20170217212610.GG6096@lunn.ch>
References: <20170217150531.2181-1-vivien.didelot@savoirfairelinux.com>
 <20170217150531.2181-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170217150531.2181-2-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 17, 2017 at 10:05:26AM -0500, Vivien Didelot wrote:
> Add a mv88e6xxx_port_mask() helper to get the bitmask of ports in a
> switch chip, that will be used in several features.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
