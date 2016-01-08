From: David Miller <davem@davemloft.net>
Subject: Re: [patch] irda: toim3232-sir: delete some dead code
Date: Fri, 08 Jan 2016 13:27:41 -0500 (EST)
Message-ID: <20160108.132741.1446598974134094010.davem@davemloft.net>
References: <20160108110404.GL32195@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60575 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755874AbcAHS1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 13:27:45 -0500
In-Reply-To: <20160108110404.GL32195@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 8 Jan 2016 14:04:04 +0300

> I noticed this code because it has a typo in the module_param(),
> the "trs" at the end of "toim3232fliptrs" should be "rts".  But it's
> dead code so instead of fixing it, I just deleted it.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Also applied, thanks Dan.
