From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ll_temac: Fix DMA map size bug
Date: Tue, 12 May 2015 23:18:14 -0400 (EDT)
Message-ID: <20150512.231814.973421258533609463.davem@davemloft.net>
References: <66b8efd7a63674220d55a03d0220897bd8b8712b.1431410769.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, soren.brinkmann@xilinx.com,
	monstr@monstr.eu, fabf@skynet.be, linux-kernel@vger.kernel.org,
	manuel.schoelling@gmx.de, julia.lawall@lip6.fr,
	elfring@users.sourceforge.net, subbaraya.sundeep.bhatta@xilinx.com,
	linux-arm-kernel@lists.infradead.org
To: michal.simek@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49111 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934319AbbEMDSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 23:18:16 -0400
In-Reply-To: <66b8efd7a63674220d55a03d0220897bd8b8712b.1431410769.git.michal.simek@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Simek <michal.simek@xilinx.com>
Date: Tue, 12 May 2015 08:06:15 +0200

> DMA allocates skb->len instead of headlen
> which is used for DMA.
> 
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>

Applied, thank you.
