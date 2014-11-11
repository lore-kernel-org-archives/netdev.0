From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: Remove IRDA_<TYPE> logging macros
Date: Tue, 11 Nov 2014 18:11:39 -0500 (EST)
Message-ID: <20141111.181139.1304217154913122671.davem@davemloft.net>
References: <1415740421.16070.11.camel@perches.com>
	<20141111.162257.701721486580745428.davem@davemloft.net>
	<1415741850.16070.13.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34939 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752424AbaKKXLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 18:11:44 -0500
In-Reply-To: <1415741850.16070.13.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 11 Nov 2014 13:37:30 -0800

> And use the more common mechanisms directly.
> 
> Other miscellanea:
> 
> o Coalesce formats
> o Add missing newlines
> o Realign arguments
> o Remove unnecessary OOM message logging as
>   there's a generic stack dump already on OOM.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> 
> Some long line warnings still exist for individual variables.
> switch/case style was also not changed.

Looks good, applied, thanks Joe.
