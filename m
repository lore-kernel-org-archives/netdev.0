From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] tipc: fix sparse non static symbol warnings
Date: Sun, 20 Jul 2014 22:19:17 -0700 (PDT)
Message-ID: <20140720.221917.617082228174513230.davem@davemloft.net>
References: <1405833268-6630-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, allan.stephens@windriver.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53572 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752224AbaGUFTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 01:19:23 -0400
In-Reply-To: <1405833268-6630-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: weiyj_lk@163.com
Date: Sun, 20 Jul 2014 13:14:28 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fixes the following sparse warnings:
> 
> net/tipc/socket.c:545:5: warning:
>  symbol 'tipc_sk_proto_rcv' was not declared. Should it be static?
> net/tipc/socket.c:2015:5: warning:
>  symbol 'tipc_ioctl' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thank you.
