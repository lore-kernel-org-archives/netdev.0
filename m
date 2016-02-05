From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smc911x: convert pxa dma to dmaengine
Date: Fri, 05 Feb 2016 17:30:21 -0500 (EST)
Message-ID: <20160205.173021.1388372628450225378.davem@davemloft.net>
References: <20151202.235217.2201517065767030121.davem@davemloft.net>
	<87fuzjl69l.fsf@belgarion.home>
	<87k2mi4ysn.fsf@belgarion.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maramaopercheseimorto@gmail.com, g.liakhovetski@gmx.de,
	mitake@dcl.info.waseda.ac.jp, fabio.estevam@freescale.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: robert.jarzmik@free.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87k2mi4ysn.fsf@belgarion.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Jarzmik <robert.jarzmik@free.fr>
Date: Fri, 05 Feb 2016 22:44:56 +0100

> Apart from Alberto who answered he cannot test it by lack of hardware, the
> others didn't answer.
> 
> So how can I move forward ? Would you want me to amend the KConfig to add a "&&
> !ARCH_PXA" on the "depend" line ?

Please just keep pinging people to properly test this.
