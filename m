From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] ip_tunnel: fix sparse non static symbol warning
Date: Thu, 09 Jan 2014 14:33:21 -0500 (EST)
Message-ID: <20140109.143321.1167180841126239598.davem@davemloft.net>
References: <CAPgLHd__qSufRW4YE63SocWV1gcgzBCBX1bdy+WcJ7v8zhE8qw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, therbert@google.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33196 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543AbaAITdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 14:33:25 -0500
In-Reply-To: <CAPgLHd__qSufRW4YE63SocWV1gcgzBCBX1bdy+WcJ7v8zhE8qw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Wed, 8 Jan 2014 21:59:30 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fixes the following sparse warning:
> 
> net/ipv4/ip_tunnel.c:116:18: warning:
>  symbol 'tunnel_dst_check' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
