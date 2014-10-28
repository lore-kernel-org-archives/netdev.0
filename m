From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skbuff.h: fix kernel-doc warning for headers_end
Date: Tue, 28 Oct 2014 17:02:51 -0400 (EDT)
Message-ID: <20141028.170251.784286549462098361.davem@davemloft.net>
References: <544DAA6E.4090509@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rdunlap@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35964 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbaJ1VCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 17:02:54 -0400
In-Reply-To: <544DAA6E.4090509@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>
Date: Sun, 26 Oct 2014 19:14:06 -0700

> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix kernel-doc warning in <linux/skbuff.h> by making both headers_start
> and headers_end private fields.
> 
> Warning(..//include/linux/skbuff.h:654): No description found for parameter 'headers_end[0]'
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

Applied, thanks a lot Randy.
