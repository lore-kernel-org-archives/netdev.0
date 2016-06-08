From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net_sched: add missing paddattr description
Date: Wed, 08 Jun 2016 11:17:53 -0700 (PDT)
Message-ID: <20160608.111753.1478065057070590396.davem@davemloft.net>
References: <1465391985.7945.4.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38227 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161084AbcFHSR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 14:17:56 -0400
In-Reply-To: <1465391985.7945.4.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 08 Jun 2016 06:19:45 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> "make htmldocs" complains otherwise:
> 
> .//net/core/gen_stats.c:65: warning: No description found for parameter 'padattr'
> .//net/core/gen_stats.c:101: warning: No description found for parameter 'padattr'
> 
> 
> Fixes: 9854518ea04d ("sched: align nlattr properly when needed")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>

Applied, thanks.
