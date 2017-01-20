From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v5 2/2] net: dsa: mv88e6xxx: Add support for ethernet switch 88E6341
Date: Fri, 20 Jan 2017 12:30:16 -0500
Message-ID: <87lgu5r653.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170119214934.27442-1-gregory.clement@free-electrons.com> <20170119214934.27442-3-gregory.clement@free-electrons.com> <87y3y6k7pg.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <20170120001203.GB31483@lunn.ch> <8760l9641t.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
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
To: Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8760l9641t.fsf@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gregory,

Gregory CLEMENT <gregory.clement@free-electrons.com> writes:

> If there a series about to be merged I can rebase my series on it. Else
> I propose to keep it and convert the family check to ops when you will
> send the series for it.

I am reworking the VTU operations, but not these port operations yet.
I will take care of converting the family checks once I'm done, don't
worry ;)

> I confirm that 6141 and 6341 are called Topaz. Actually I can add the
> support for the 6141 too, it is just a matter of adding an ID and maybe
> removing some ops as 6141 is a subset of 6341.

I don't mind having a patch adding support for only one chip at a time,
that is up to you.

Thanks,

        Vivien
