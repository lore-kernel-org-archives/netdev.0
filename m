From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [IPSEC] Move generic encap code into xfrm6_output
Date: Sun, 25 Jul 2004 09:36:17 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040725.093617.15482200.yoshfuji@linux-ipv6.org>
References: <20040725104028.GA24547@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, davem@redhat.com, jmorris@redhat.com,
        netdev@oss.sgi.com, kazunori@miyazawa.org, yoshfuji@linux-ipv6.org,
        usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20040725104028.GA24547@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040725104028.GA24547@gondor.apana.org.au> (at Sun, 25 Jul 2004 20:40:28 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> Here is the IPv6 version of the generic tunnel encapsulation code.

Well, since we're on the way back to home from OLS,
we'll review when we're back to Japan.

One thing: please retain our credit in net/ipv6/xfrm6_output.c.

Thank you.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
