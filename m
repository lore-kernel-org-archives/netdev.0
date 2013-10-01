From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add missing sk_max_pacing_rate doc
Date: Mon, 30 Sep 2013 22:11:41 -0700 (PDT)
Message-ID: <20130930.221141.2224536912493020168.davem@davemloft.net>
References: <1380036052.3165.71.camel@edumazet-glaptop>
	<20130928.153610.2280100769720851440.davem@davemloft.net>
	<1380442360.3596.18.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42572 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191Ab3JAFEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 01:04:36 -0400
In-Reply-To: <1380442360.3596.18.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 29 Sep 2013 01:12:40 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Warning(include/net/sock.h:411): No description found for parameter
> 'sk_max_pacing_rate'
> 
> Lets please "make htmldocs" and kbuild bot.
> 
> Reported-by: Wu Fengguang <fengguang.wu@intel.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
