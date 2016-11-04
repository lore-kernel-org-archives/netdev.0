From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 00/11] net: dsa: mv88e6xxx: refine port
 operations
Date: Fri, 4 Nov 2016 10:31:34 +0100
Message-ID: <20161104093134.GE13959@lunn.ch>
References: <20161104022336.14273-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161104022336.14273-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 04, 2016 at 03:23:25AM +0100, Vivien Didelot wrote:
> The Marvell chips have one internal SMI device per port, containing a
> set of registers used to configure a port's link, STP state, default
> VLAN or addresses database, etc.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
