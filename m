From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 0/3] net: dsa: add MDB support
Date: Wed, 31 Aug 2016 18:04:05 +0200
Message-ID: <20160831160405.GA11775@lunn.ch>
References: <20160831155005.2569-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160831155005.2569-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 31, 2016 at 11:50:02AM -0400, Vivien Didelot wrote:
> This patchset adds the switchdev MDB object support to the DSA layer.
> 
> The MDB support for the mv88e6xxx driver is very similar to the FDB
> support. The FDB operations care about unicast addresses while the MDB
> operations care about multicast addresses.
> 
> Both operation set load/purge/dump the Address Translation Table (ATU),
> thus common code is used.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Thanks
    Andrew
