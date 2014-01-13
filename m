From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] gre_offload: fix sparse non static symbol warning
Date: Mon, 13 Jan 2014 11:38:27 -0800 (PST)
Message-ID: <20140113.113827.642732697933956155.davem@davemloft.net>
References: <CAPgLHd_s+M1XkL+Bf-Zd8CtOyt0aaOaNLRevO2JK=oX8zunR4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xeb@mail.ru, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38112 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751679AbaAMTi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 14:38:28 -0500
In-Reply-To: <CAPgLHd_s+M1XkL+Bf-Zd8CtOyt0aaOaNLRevO2JK=oX8zunR4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Thu, 9 Jan 2014 22:22:05 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fixes the following sparse warning:
> 
> net/ipv4/gre_offload.c:253:5: warning:
>  symbol 'gre_gro_complete' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thank you.
