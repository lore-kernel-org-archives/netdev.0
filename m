From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] net: powerpc: remove the legacy iSeries ethernet
 driver
Date: Wed, 07 Mar 2012 22:53:17 -0800 (PST)
Message-ID: <20120307.225317.837723066642024990.davem@davemloft.net>
References: <20120308152853.b5010336abbb8f90e8a2500c@canb.auug.org.au>
	<20120308153353.ee2ff35c8ebe7ee66fa374e9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58200 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751491Ab2CHG5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 01:57:30 -0500
In-Reply-To: <20120308153353.ee2ff35c8ebe7ee66fa374e9@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 8 Mar 2012 15:33:53 +1100

> This driver is specific to the PowerPC legcay iSeries platform which is
> being removed.
> 
> Cc: David Miller <davem@davemloft.net>
> Cc: <netdev@vger.kernel.org>
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Acked-by: David S. Miller <davem@davemloft.net>
