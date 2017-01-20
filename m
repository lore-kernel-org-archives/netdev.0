From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v5 2/2] net: dsa: mv88e6xxx: Add support for ethernet
 switch 88E6341
Date: Sat, 21 Jan 2017 00:15:15 +0100
Message-ID: <20170120231515.GB25240@lunn.ch>
References: <20170119214934.27442-1-gregory.clement@free-electrons.com>
 <20170119214934.27442-3-gregory.clement@free-electrons.com>
 <87y3y6k7pg.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20170120001203.GB31483@lunn.ch>
 <8760l9641t.fsf@free-electrons.com>
 <87lgu5r653.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Nadav Haklai <nadavh@marvell.com>,
        Wilson Ding <dingwei@marvell.com>,
        Kostya Porotchkin <kostap@marvell.com>,
        Joe Zhou <shjzhou@marvell.com>,
        Jon Pannell <jpannell@marvell.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87lgu5r653.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 20, 2017 at 12:30:16PM -0500, Vivien Didelot wrote:
> Hi Gregory,
> 
> Gregory CLEMENT <gregory.clement@free-electrons.com> writes:
> 
> > If there a series about to be merged I can rebase my series on it. Else
> > I propose to keep it and convert the family check to ops when you will
> > send the series for it.
> 
> I am reworking the VTU operations, but not these port operations yet.

I'm working on them. I have a patch ready for testing on my hardware.

    Andrew
