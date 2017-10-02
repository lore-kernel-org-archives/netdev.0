From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] net: mvpp2: Fix clock resource by adding an
 optional bus clock
Date: Sun, 01 Oct 2017 22:51:59 -0700 (PDT)
Message-ID: <20171001.225159.2176517451167649617.davem@davemloft.net>
References: <20170929122739.5296-1-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        jason@lakedaemon.net, andrew@lunn.ch,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com,
        linux-arm-kernel@lists.infradead.org,
        antoine.tenart@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        shadi@marvell.com, yehuday@marvell.com, omrii@marvell.com,
        hannah@marvell.com, igall@marvell.com, mw@semihalf.com
To: gregory.clement@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170929122739.5296-1-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Date: Fri, 29 Sep 2017 14:27:39 +0200

> On Armada 7K/8K we need to explicitly enable the bus clock. The bus clock
> is optional because not all the SoCs need them but at least for Armada
> 7K/8K it is actually mandatory.
> 
> The binding documentation is updating accordingly.
> 
> Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>

Applied.
