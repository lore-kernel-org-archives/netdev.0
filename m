From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6 3/4] macvlan: 64 bit rx counters
Date: Thu, 24 Jun 2010 16:55:23 +0200
Message-ID: <4C2371DB.8070202@trash.net>
References: <1277376861.2816.284.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35318 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755773Ab0FXOzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 10:55:48 -0400
In-Reply-To: <1277376861.2816.284.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Use u64_stats_sync infrastructure to implement 64bit stats.
>
>   

Looks good to me, thanks, I actually wanted to do this myself yesterday :)

Acked-by: Patrick McHardy <kaber@trash.net>

