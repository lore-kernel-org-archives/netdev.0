From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [IPSEC] Merge xfrm4_bundle_ok/xfrm6_bundle_ok/stale_bundle
Date: Sat, 29 Jan 2005 22:47:21 +0900 (JST)
Message-ID: <20050129.224721.131964551.yoshfuji@linux-ipv6.org>
References: <20050129123803.GA17390@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050129123803.GA17390@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050129123803.GA17390@gondor.apana.org.au> (at Sat, 29 Jan 2005 23:38:03 +1100), Herbert Xu <herbert@gondor.apana.org.au> says:

> This patch merges __xfrm4_bundle_ok/__xfrm6_bundle_ok/stale_bundle
> so that when I add MTU verification code I don't have to put it in
> three places.

Ok, I agree.

--yoshfuji
