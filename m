From: David Miller <davem@davemloft.net>
Subject: Re: netlink: Disable insertions/removals during rehash
Date: Thu, 04 Jun 2015 11:59:22 -0700 (PDT)
Message-ID: <20150604.115922.1489867293287036693.davem@davemloft.net>
References: <20150516131628.GA981@gondor.apana.org.au>
	<20150516.171019.1206903516753105739.davem@davemloft.net>
	<20150604162727.GA2670@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, eric.dumazet@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org
To: linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49285 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753957AbbFDS7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 14:59:23 -0400
In-Reply-To: <20150604162727.GA2670@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>
Date: Thu, 4 Jun 2015 09:27:27 -0700

> sorry for bothering you - I don't see this patch in any of your trees,
> and it is marked as "changes requested" in patchwork. Did I look
> at the wrong places, do you still plan to apply the patch as-is,
> or do you expect some changes ?
> 
> As side info, I have been trying to track down the getaddrinfo
> hang problem observed by others, which we see in 3.19.4 and 4.0.4.

Changes-requested, amazingly, means that someone gave you feedback
and changes along with a fresh resubmission is expected of you.
