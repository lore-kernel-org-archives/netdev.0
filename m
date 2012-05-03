From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-next 2012-05-03
Date: Thu, 03 May 2012 13:21:26 -0400 (EDT)
Message-ID: <20120503.132126.1970020317749906187.davem@davemloft.net>
References: <20120503152206.GL9285@tuxdriver.com>
	<20120503.130516.1008806127286088740.davem@davemloft.net>
	<20120503.131707.112550136096227430.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45498 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063Ab2ECRWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 13:22:32 -0400
In-Reply-To: <20120503.131707.112550136096227430.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 03 May 2012 13:17:07 -0400 (EDT)

> Really, we went through this a million times very recently and I'm
> not pulling anything into my tree that has garbage like this in it.

BTW, the bluetooth guys owe John Linville a serious apology.

Because of the crap situation they've created, I can no longer
trust John's pulls.

That means I have to baby-sit every pull request he sends me and
go through every single patch in it looking for these kinds of
problems.

This is _NOT_ how this is supposed to work.

John should be sending me things that are fully vetted and I can
basically trust to be in good shape.  But because of the bluetooth
guys that is not the case.
