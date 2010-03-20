From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch] bridge: cleanup: remove unused assignment
Date: Sat, 20 Mar 2010 19:57:47 +0800
Message-ID: <20100320115747.GA1849@gondor.apana.org.au>
References: <20100320112049.GU5331@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Michael Braun <michael-dev@fami-braun.de>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41297 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750797Ab0CTL6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 07:58:08 -0400
Content-Disposition: inline
In-Reply-To: <20100320112049.GU5331@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 20, 2010 at 02:20:49PM +0300, Dan Carpenter wrote:
> We never actually use iph again so this assignment can be removed.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
