From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/3] net: mvpp2: fix typo in the tcam setup
Date: Thu, 26 Oct 2017 17:08:17 +0900 (KST)
Message-ID: <20171026.170817.1555121131584399564.davem@davemloft.net>
References: <20171024094128.24433-1-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux-kernel@vger.kernel.org, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org
To: antoine.tenart@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024094128.24433-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Date: Tue, 24 Oct 2017 11:41:26 +0200

> This patch fixes a typo in the mvpp2_prs_tcam_data_cmp() function, as
> the shift value is inverted with the data.
> 
> Fixes: 3f518509dedc ("ethernet: Add new driver for Marvell Armada 375 network unit")
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>

Applied.
