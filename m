From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tg3: use netdev_alloc_frag() API
Date: Sat, 19 May 2012 04:01:01 -0400 (EDT)
Message-ID: <20120519.040101.508727755785767140.davem@davemloft.net>
References: <1337411749.7029.77.camel@edumazet-glaptop>
	<20120519.031914.1744866102736414778.davem@davemloft.net>
	<1337412701.7029.79.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48171 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964790Ab2ESIBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 04:01:07 -0400
In-Reply-To: <1337412701.7029.79.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 19 May 2012 09:31:41 +0200

> Indeed, there is an extra space at the end of one line in my tree... ???
> 
> atomic_add((PAGE_SIZE / TG3_FRAGSIZE) - 1, &page->_count); <HERE>

I silently fix trailing whitespace errors in your patches.
