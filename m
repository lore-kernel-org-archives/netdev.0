From: David Miller <davem@davemloft.net>
Subject: Re: pull request: bluetooth-next 2012-03-01
Date: Sat, 03 Mar 2012 15:06:54 -0500 (EST)
Message-ID: <20120303.150654.991645679389171627.davem@davemloft.net>
References: <20120303164655.GA5275@joana>
	<20120303.144722.764199641223280924.davem@davemloft.net>
	<1330805060.7070.18.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: padovan@profusion.mobi, gustavo@padovan.org,
	johan.hedberg@gmail.com, linville@tuxdriver.com,
	marcel@holtmann.org, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38861 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753540Ab2CCUIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2012 15:08:07 -0500
In-Reply-To: <1330805060.7070.18.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sat, 03 Mar 2012 12:04:20 -0800

> It's your choice but I personally think you should
> give the bluetooth folk a chance to change their style
> in a single largish whitespace commit immediately post
> 3.4 akin to the recent isdn one you just pulled.

They didn't just continue to use existing coding style, they also
screwed up things that were done correctly.

The struct member tabbing thing is just one example.

I already gave them a free one-time pull even though I disagreed with
what was in their tree.  I'm not going to continually review new code
that isn't styled properly.
