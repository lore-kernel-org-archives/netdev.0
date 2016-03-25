From: David Miller <davem@davemloft.net>
Subject: Re: veth regression with =?iso-8859-7?B?ImRvbqJ0?= modify
 ip_summed; doing so treats packets with bad checksums as good."
Date: Fri, 25 Mar 2016 15:00:24 -0400 (EDT)
Message-ID: <20160325.150024.1646139617211983730.davem@davemloft.net>
References: <56F56312.4080408@candelatech.com>
	<20160325.124427.273071525698476869.davem@davemloft.net>
	<56F57206.5000701@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, vijayp@vijayp.ca, netdev@vger.kernel.org,
	ej@evanjones.ca, cwang@twopensource.com, tom@herbertland.com
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44687 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753254AbcCYTA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 15:00:29 -0400
In-Reply-To: <56F57206.5000701@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Fri, 25 Mar 2016 10:14:46 -0700

> Anyway, you know the stack and drivers better than me, so if you
> think Cong's patch is valid, then I'll test it and make sure it
> works in my setups at least.

It probably is, I'm just waiting to see if Tom Herbert will give
some feedback or not as this is an area he understands well.
