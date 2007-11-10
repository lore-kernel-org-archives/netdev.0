From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: UDP-Lite and /proc/net/snmp
Date: Sat, 10 Nov 2007 22:55:37 +0800
Message-ID: <20071110145536.GA7024@gondor.apana.org.au>
References: <20071110131428.GA6447@gondor.apana.org.au> <20071110.223243.114494952.yoshfuji@linux-ipv6.org> <20071110143325.GA6888@gondor.apana.org.au> <20071110.234854.10674315.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2994 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750944AbXKJOzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Nov 2007 09:55:46 -0500
Content-Disposition: inline
In-Reply-To: <20071110.234854.10674315.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 10, 2007 at 11:48:54PM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
>
> Hmm..... "netstat -s" from etch (i386) and etch (x86_64) work
> fine for me.  Same version, same architecture.  Strange...

Interesting.  What does your /proc/net/snmp file look like?
And what does netstat -s actually produce?

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
