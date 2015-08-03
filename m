From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fddi: Use a more more typical logging style
Date: Mon, 03 Aug 2015 16:05:15 -0700 (PDT)
Message-ID: <20150803.160515.553677819137228534.davem@davemloft.net>
References: <1438576065.30149.7.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45450 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932308AbbHCXFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 19:05:16 -0400
In-Reply-To: <1438576065.30149.7.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sun, 02 Aug 2015 21:27:45 -0700

> Use macros that don't require fixed argument counts so
> format and arguments can be verified by the compiler.
> 
> Miscellanea:
> 
> o Remove a few #if uses to allow dynamic debug to always work
> o whitespace neatening
> 
> Signed-off-by: Joe Perches <joe@perches.com>

This doesn't apply cleanly to net-next, please respin.
