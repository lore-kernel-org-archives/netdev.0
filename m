From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: mvpp2: remove useless goto
Date: Tue, 19 Sep 2017 13:49:23 -0700 (PDT)
Message-ID: <20170919.134923.1784738451813281488.davem@davemloft.net>
References: <20170918133651.29556-1-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org
To: antoine.tenart@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170918133651.29556-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Date: Mon, 18 Sep 2017 15:36:51 +0200

> Remove a goto in the PPv2 tx function which jumps to the next line
> anyway. This is a cosmetic commit.
> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>

Applied, thanks.
