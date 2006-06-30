From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [1/4] [IPV6]: Remove redundant length check on input
Date: Fri, 30 Jun 2006 15:03:34 +0900 (JST)
Message-ID: <20060630.150334.11795733.yoshfuji@linux-ipv6.org>
References: <20060630054209.GA28558@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ananda.Raju@neterion.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:21516 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1750763AbWF3GCe
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 02:02:34 -0400
To: herbert@gondor.apana.org.au, davem@davemloft.net
In-Reply-To: <20060630054209.GA28558@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20060630054209.GA28558@gondor.apana.org.au> (at Fri, 30 Jun 2006 15:42:09 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> [IPV6]: Remove redundant length check on input
> 
> We don't need to check skb->len when we're just about to call
> pskb_may_pull since that checks it for us.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
