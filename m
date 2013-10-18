From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fib: Use const struct nl_info * in rtmsg_fib
Date: Fri, 18 Oct 2013 14:42:38 -0400 (EDT)
Message-ID: <20131018.144238.369627074073435008.davem@davemloft.net>
References: <1382030610.22110.112.camel@joe-AO722>
	<CAKfDRXjctGkcqSt9cM=iWbckLt4=7n8434WAA8rr4_cEofEO=Q@mail.gmail.com>
	<1382042051.22110.146.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kristian.evensen@gmail.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57402 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756738Ab3JRSmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 14:42:42 -0400
In-Reply-To: <1382042051.22110.146.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Thu, 17 Oct 2013 13:34:11 -0700

> The rtmsg_fib function doesn't modify this argument so mark
> it const.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
