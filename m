From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 11/12] net: dsa: mv88e6xxx: add Energy Detect ops
Date: Tue, 18 Jul 2017 21:58:41 +0200
Message-ID: <20170718195841.GC12449@lunn.ch>
References: <20170717210405.GC11719@lunn.ch>
 <20170717.141048.999243831453421230.davem@davemloft.net>
 <e65f425d-d6c2-f1c3-ea92-c2a0878add44@gmail.com>
 <20170718.104636.315406311682846961.davem@davemloft.net>
 <87d18xpo4f.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87d18xpo4f.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I know this looks boring, I do not particularly enjoy it myself, but I
> think this is also important. I don't mind fixing the poking function as
> well in the near future.

It would be great if you do. It could be as simple as using
phy_ethtool_get_eee() and phy_ethtool_set_eee().

      Andrew
