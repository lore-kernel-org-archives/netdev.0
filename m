From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v7 2/3] net: dsa: mv88e6xxx: Add support for ethernet switch 88E6341
Date: Mon, 30 Jan 2017 14:43:48 -0500
Message-ID: <877f5cl4ej.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <cover.69cbc1ba8937d0fc442538f992d62fc88aa26dcc.1485804488.git-series.gregory.clement@free-electrons.com> <e3122f300fd144e2b4ae299d74fe1e72389583bb.1485804488.git-series.gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Nadav Haklai <nadavh@marvell.com>,
        Wilson Ding <dingwei@marvell.com>,
        Kostya Porotchkin <kostap@marvell.com>,
        Joe Zhou <shjzhou@marvell.com>,
        Jon Pannell <jpannell@marvell.com>,
        Bob Bernstein <robertb@marvell.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e3122f300fd144e2b4ae299d74fe1e72389583bb.1485804488.git-series.gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gregory,

Gregory CLEMENT <gregory.clement@free-electrons.com> writes:

> The Marvell 88E6341 device is single-chip, 6-port Ethernet switch with
> four integrated 10/100/1000Mbps Ethernet transceivers and one high speed
> SerDes interfaces. It is partially compatible with switches of family
> 88E6352 and switches of family 88E6390.
>
> This commit adds an initial support for this switch by describing its
> capabilities to the driver and introducing a new family.
>
> Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
