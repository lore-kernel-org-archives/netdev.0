From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] packetengines: fix config default
Date: Fri, 02 Mar 2012 19:06:40 -0500 (EST)
Message-ID: <20120302.190640.1175509326287357438.davem@davemloft.net>
References: <20120302153856.4352ae3c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59860 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965489Ab2CCAIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2012 19:08:46 -0500
In-Reply-To: <20120302153856.4352ae3c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 2 Mar 2012 15:38:56 -0800

> As part of the big network driver reorg, each vendor directory defaults to
> yes, so that older config's can migrate correctly. Looks like this one
> got missed.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> ---
> Patch should go to -net for 3.3

Applied and queued up for -stable, thanks.
