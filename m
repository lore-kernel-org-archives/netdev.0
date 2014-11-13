From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: Fix build failures after IRDA_DEBUG->pr_debug
Date: Wed, 12 Nov 2014 22:01:48 -0500 (EST)
Message-ID: <20141112.220148.424378481460202126.davem@davemloft.net>
References: <20141112.135719.707307878615480184.davem@davemloft.net>
	<1415840172.4269.1.camel@perches.com>
	<1415844947.4269.5.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org, fengguang.wu@intel.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49763 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753635AbaKMDBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 22:01:51 -0500
In-Reply-To: <1415844947.4269.5.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 12 Nov 2014 18:15:47 -0800

> Fix the build failures that result from the use of pr_debug
> without the referenced char * arrays being defined.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
 ...
> Let me know if you want this as a a patch or a
> reversion followed by a consolidated new version.

I'll just apply this patch, it's the cleanest thing to do at this
point.

Thanks.
