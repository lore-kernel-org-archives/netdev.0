From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [INET] Optimise away a branch in IP_ECN_set_ce
Date: Thu, 09 Sep 2004 10:58:03 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909.105803.103588005.yoshfuji@linux-ipv6.org>
References: <20040909011016.GA9238@gondor.apana.org.au>
	<20040909.102736.94408944.yoshfuji@linux-ipv6.org>
	<20040909015442.GA12935@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, herbert@gondor.apana.org.au
In-Reply-To: <20040909015442.GA12935@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040909015442.GA12935@gondor.apana.org.au> (at Thu, 9 Sep 2004 11:54:42 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> Sorry, you're right.  Here is an updated patch.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
