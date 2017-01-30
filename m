From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v7 3/3] net: dsa: mv88e6xxx: Add support for
 ethernet switch 88E6141
Date: Mon, 30 Jan 2017 14:44:48 -0500
Message-ID: <874m0gl4cv.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <cover.69cbc1ba8937d0fc442538f992d62fc88aa26dcc.1485804488.git-series.gregory.clement@free-electrons.com>
 <4a96ab0b31a1617372cdbfab67e7ba585e10f984.1485804488.git-series.gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Bob Bernstein <robertb@marvell.com>, Jason Cooper <jason@lakedaemon.net>,
 Joe Zhou <shjzhou@marvell.com>, Jon Pannell <jpannell@marvell.com>,
 Nadav Haklai <nadavh@marvell.com>, Kostya Porotchkin <kostap@marvell.com>,
 Gregory CLEMENT <gregory.clement@free-electrons.com>,
 Wilson Ding <dingwei@marvell.com>, "David S. Miller" <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>,
 Andrew Lunn <andrew@lunn.ch>, Florian Fainelli <f.fainelli@gmail.com>,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <4a96ab0b31a1617372cdbfab67e7ba585e10f984.1485804488.git-series.gregory.clement@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Gregory,

Gregory CLEMENT <gregory.clement@free-electrons.com> writes:

> The Marvell 88E6341 device is single-chip, 6-port Ethernet switch with
> four integrated 10/100/1000Mbps Ethernet transceivers and one high speed
> SerDes interfaces.

I'm sure you meant 88E6141 here ;-)

> It belongs to the Topaz family and unlike the 88E6341 it does not have
> a TCAM.
>
> Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
