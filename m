From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [3/5] [NET]: Add software TSOv4
Date: Fri, 23 Jun 2006 00:04:03 +0900 (JST)
Message-ID: <20060623.000403.47759894.yoshfuji@linux-ipv6.org>
References: <20060622081211.GA22505@gondor.apana.org.au>
	<20060622081400.GC22671@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:21000 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1751809AbWFVPDJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 11:03:09 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060622081400.GC22671@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20060622081400.GC22671@gondor.apana.org.au> (at Thu, 22 Jun 2006 18:14:00 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> [NET]: Add software TSOv4
> 
> This patch adds the GSO implementation for IPv4 TCP.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I'd appreciate if you code up IPv6 TCP as well. :-)

Regards,

--yoshfuji
