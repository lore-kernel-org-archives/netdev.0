From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Update kernel-doc for __alloc_skb()
Date: Thu, 07 Jun 2012 13:19:22 -0700 (PDT)
Message-ID: <20120607.131922.1804186940519791648.davem@davemloft.net>
References: <jqoe5d$fs3$1@dough.gmane.org>
	<1339032217.2836.61.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, grant.b.edwards@gmail.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45457 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752699Ab2FGUTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 16:19:22 -0400
In-Reply-To: <1339032217.2836.61.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 7 Jun 2012 02:23:37 +0100

> __alloc_skb() now extends tailroom to allow the use of padding added
> by the heap allocator.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
