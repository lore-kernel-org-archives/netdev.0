From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v5 0/2] Add support for the ethernet switch on the
 ESPRESSObin
Date: Fri, 20 Jan 2017 18:43:21 +0100
Message-ID: <20170120174321.GF25907@lunn.ch>
References: <20170119214934.27442-1-gregory.clement@free-electrons.com>
 <20170119220607.GA25907@lunn.ch>
 <87a8al64mp.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
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
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87a8al64mp.fsf@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> What I wanted to do was to test 6390 and 6352 temperature related
> functions and to see if one of them worked. That's how I realized it was
> not possible to do it with dsa2.

Hi Gregory

Probably the best thing to do is wait until the temperature code moves
into the PHY driver. It then becomes easier to test. It probably is
the same as the 6352, or like the 6390 which i've so far failed to get
working, despite the registers being the same as the 6352.

     Andrew
