From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] Marvell Armada 375 mvpp2 fixes
Date: Fri, 04 Dec 2015 15:01:37 -0500 (EST)
Message-ID: <20151204.150137.97964032407636739.davem@davemloft.net>
References: <1449152451-2939-1-git-send-email-mw@semihalf.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, linux@arm.linux.org.uk,
	sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
	jason@lakedaemon.net, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com,
	ezequiel.garcia@free-electrons.com, nadavh@marvell.com,
	alior@marvell.com, jaz@semihalf.com, tn@semihalf.com
To: mw@semihalf.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449152451-2939-1-git-send-email-mw@semihalf.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcin Wojtas <mw@semihalf.com>
Date: Thu,  3 Dec 2015 15:20:48 +0100

> During my work on mvneta driver I revised mvpp2, and it occurred that the
> initial version of Marvell Armada 375 SoC comprised bugs around
> DMA-unmapping in both ingress and egress paths - not all buffers were
> umapped in TX path and none(!) in RX. Three patches that I send fix
> this situation.
> 
> Any feedback would be welcome.

Series applied, thank you.
