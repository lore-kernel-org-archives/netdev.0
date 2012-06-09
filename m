From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core: fix kernel-doc warnings
Date: Fri, 08 Jun 2012 22:21:11 -0700 (PDT)
Message-ID: <20120608.222111.780223138922648196.davem@davemloft.net>
References: <4FD29268.1010604@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rdunlap@xenotime.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54776 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813Ab2FIFVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 01:21:12 -0400
In-Reply-To: <4FD29268.1010604@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@xenotime.net>
Date: Fri, 08 Jun 2012 17:01:44 -0700

> From: Randy Dunlap <rdunlap@xenotime.net>
> 
> Fix kernel-doc warnings in net/core:
> 
> Warning(net/core/skbuff.c:3368): No description found for parameter 'delta_truesize'
> Warning(net/core/filter.c:628): No description found for parameter 'pfp'
> Warning(net/core/filter.c:628): Excess function parameter 'sk' description in 'sk_unattached_filter_create'
> 
> Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>

Applied.
