From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: return errno pointers consistently for
 fib6_add_1()
Date: Fri, 28 Sep 2012 18:49:17 -0400 (EDT)
Message-ID: <20120928.184917.794228094103991094.davem@davemloft.net>
References: <1348622227.4935.1.camel@minggr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mlin@ss.pku.edu.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45696 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964934Ab2I1WtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 18:49:18 -0400
In-Reply-To: <1348622227.4935.1.camel@minggr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lin Ming <mlin@ss.pku.edu.cn>
Date: Wed, 26 Sep 2012 09:17:07 +0800

> fib6_add_1() should consistently return errno pointers,
> rather than a mixture of NULL and errno pointers.
> 
> Signed-off-by: Lin Ming <mlin@ss.pku.edu.cn>

Applied, thanks.
