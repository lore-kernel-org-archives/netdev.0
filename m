From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Oops when stopping IPsec connection
Date: Fri, 24 Sep 2004 01:15:18 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095981318.6198.0.camel@pegasus>
References: <E1CAbiX-00016Q-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Network Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CAbiX-00016Q-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Herbert,

> > EIP is at fib_nh_match+0x58/0x61
> >
> > Call Trace:
> > [<c02680dd>] fn_hash_delete+0x231/0x243
> > [<c02657d1>] inet_rtm_delroute+0x66/0x7a
> 
> Does this patch help?

yes, this works for me. Thanks.

Regards

Marcel
