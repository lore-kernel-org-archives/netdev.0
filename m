From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Pull request for mv643xx_eth 'for-2.6.27' branch
Date: Tue, 10 Jun 2008 18:15:15 -0400
Message-ID: <484EFCF3.4020703@garzik.org>
References: <20080606113747.GA7778@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dale@farnsworth.org, netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46094 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752887AbYFJWPS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 18:15:18 -0400
In-Reply-To: <20080606113747.GA7778@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek wrote:
> Jeff,
> 
> Please pull the following mv643xx_eth patches for 2.6.27.  (They
> were all ACKed by Dale, and I've agreed to take over mv643xx_eth
> maintainership from him.)
> 
> 
> thanks,
> Lennert
> 
> 
> 
> The following changes since commit 39b945a37bac2b692773a470890c8ba301485b15:
>   Linus Torvalds (1):
>         Merge master.kernel.org:/home/rmk/linux-2.6-arm
> 
> are available in the git repository at:
> 
>   git://git.marvell.com/mv643xx_eth.git for-2.6.27
> 
> Dale Farnsworth (1):
>       mv643xx_eth: new maintainer
> 
> Lennert Buytenhek (38):
>       mv643xx_eth: reverse topological sort of functions
>       mv643xx_eth: trim unnecessary includes
>       mv643xx_eth: shorten reg names
>       mv643xx_eth: get rid of individual port config register bit defines
>       mv643xx_eth: get rid of individual port config extend register bit defines
>       mv643xx_eth: delete unused SDMA config register bit defines
>       mv643xx_eth: delete unused port serial control register bit defines
>       mv643xx_eth: nuke port status register bit defines
>       mv643xx_eth: remove unused DESC_SIZE define
>       mv643xx_eth: clarify irq masking and unmasking
>       mv643xx_eth: move PHY wait defines into callers
>       mv643xx_eth: get rid of RX_BUF_OFFSET
>       mv643xx_eth: move MIB offset defines into their only user
>       mv643xx_eth: remove port serial status register bit defines
>       mv643xx_eth: clean up rx/tx descriptor field defines
>       mv643xx_eth: get rid of ETH_/ethernet_/eth_ prefixes
>       mv643xx_eth: use 'mv643xx_eth_' prefix consistently
>       mv643xx_eth: kill superfluous comments
>       mv643xx_eth: kill ->rx_resource_err
>       mv643xx_eth: get rid of hungarian variable naming
>       mv643xx_eth: move port_receive() into its only caller
>       mv643xx_eth: move rx_return_buff() into its only caller
>       mv643xx_eth: kill FUNC_RET_STATUS/pkt_info
>       mv643xx_eth: kill private unused instance of struct net_device_stats
>       mv643xx_eth: massively simplify multicast address crc8 computation
>       mv643xx_eth: split out rx queue state
>       mv643xx_eth: split out tx queue state
>       mv643xx_eth: remove write-only interrupt coalescing variables
>       mv643xx_eth: general cleanup
>       mv643xx_eth: add tx rate control
>       mv643xx_eth: allow multiple RX queues
>       mv643xx_eth: allow multiple TX queues
>       mv643xx_eth: work around TX hang hardware issue
>       mv643xx_eth: detect extended rx coal register field
>       mv643xx_eth: detect alternate TX BW control register location
>       mv643xx_eth: be more agressive about RX refill
>       mv643xx_eth: add PHY-less mode
>       mv643xx_eth: update driver version and author fields

ignore my last email... is this current?  or is there more?

	Jeff


