From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2] intel: Remove unnecessary OOM messages
Date: Thu, 13 Feb 2014 17:47:23 -0500 (EST)
Message-ID: <20140213.174723.1145739288167542959.davem@davemloft.net>
References: <1392168397.23721.2.camel@joe-AO722>
	<1392168652.1868.1.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50952 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751517AbaBMWrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:47:24 -0500
In-Reply-To: <1392168652.1868.1.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 11 Feb 2014 17:30:52 -0800

> Don't emit these as there's a generic OOM with a dump_stack()
> on allocation failures.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> 
> With patch attached this time...

I expect the Intel folks to pick this up.
