From: David Miller <davem@davemloft.net>
Subject: Re: Make DST_CACHE a silent config option
Date: Mon, 21 Mar 2016 22:58:05 -0400 (EDT)
Message-ID: <20160321.225805.145364101319690021.davem@davemloft.net>
References: <20160321223722.GA26702@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@codemonkey.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57197 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947AbcCVC6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 22:58:07 -0400
In-Reply-To: <20160321223722.GA26702@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@codemonkey.org.uk>
Date: Mon, 21 Mar 2016 18:37:22 -0400

> commit 911362c70d ("net: add dst_cache support") added a new
> kconfig option that gets selected by other networking options.
> It seems the intent wasn't to offer this as a user-selectable
> option given the lack of help text, so this patch converts it
> to a silent option.
> 
> Signed-off-by: Dave Jones <davej@codemonkey.org.uk>

That indeed is the intention, applied, thanks Dave.
