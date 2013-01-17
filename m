From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next (V4) 00/11] IPv6: rt->n (neighbour in
 rt6_info) removal, TAKE 4.
Date: Thu, 17 Jan 2013 18:40:55 -0500 (EST)
Message-ID: <20130117.184055.706437402303529368.davem@davemloft.net>
References: <50F880C3.2050409@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55011 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808Ab3AQXk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 18:40:56 -0500
In-Reply-To: <50F880C3.2050409@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Fri, 18 Jan 2013 07:52:51 +0900

> This is "TAKE 4" of neighbour removal from rt6_info.
> 
> 3->4:
> - error check in ip6_finish_output2(), in 10/11.

All applied, I'll push this out to net-next after some quick
build validations, thanks a lot!
