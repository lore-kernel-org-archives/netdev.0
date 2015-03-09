From: David Miller <davem@davemloft.net>
Subject: Re: [trivial PATCH net-next] ethernet: codespell comment spelling
 fixes
Date: Sun, 08 Mar 2015 22:54:42 -0400 (EDT)
Message-ID: <20150308.225442.1075179422753257056.davem@davemloft.net>
References: <1425703752.12017.66.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, standby24x7@gmail.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46569 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbbCICyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2015 22:54:43 -0400
In-Reply-To: <1425703752.12017.66.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri, 06 Mar 2015 20:49:12 -0800

> To test a checkpatch spelling patch, I ran codespell against
> drivers/net/ethernet/.
> 
> $ git ls-files drivers/net/ethernet/ | \
>   while read file ; do \
>     codespell -w $file; \
>   done
> 
> I removed a false positive in e1000_hw.h
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks.
