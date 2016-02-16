From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] net: ethernet: nb8800: support fixed-link DT node
Date: Tue, 16 Feb 2016 15:04:57 -0500 (EST)
Message-ID: <20160216.150457.2258135694595137673.davem@davemloft.net>
References: <56B4BDDA.9010708@laposte.net>
	<yw1xbn7vgoux.fsf@unicorn.mansr.com>
	<56B86C88.5090504@laposte.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mans@mansr.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, slash.tmp@free.fr
To: sf84@laposte.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56B86C88.5090504@laposte.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sebastian Frias <sf84@laposte.net>
Date: Mon, 08 Feb 2016 11:23:04 +0100

> 
> Under some circumstances, for example when connecting
> to a switch:
> 
> https://stackoverflow.com/questions/31046172/device-tree-for-phy-less-connection-to-a-dsa-switch
> 
> the ethernet port will not be connected to a PHY.
> In that case a "fixed-link" DT node can be used to replace it.
> 
> This patch adds support for the "fixed-link" node to the
> nb8800 driver.
> 
> Signed-off-by: Sebastian Frias <sf84@laposte.net>

This doesn't apply, please respin against my tree.
