From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 3756] New: oops during raid rebuild (ServeRAID 6M)
Date: Wed, 17 Nov 2004 22:28:56 +1100
Message-ID: <E1CUNzc-00042t-00@gondolin.me.apana.org.au>
References: <20041117012902.7deecd8e.akpm@osdl.org>
Cc: netdev@oss.sgi.com, janfrode@parallab.uib.no
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org (Andrew Morton)
In-Reply-To: <20041117012902.7deecd8e.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
> 
> Call Trace:
> [<c0383633>] tcp_rcv_synsent_state_process+0x50c/0x561
> [<c0383fc0>] tcp_rcv_state_process+0x938/0xa1c
> [<c038b72f>] tcp_v4_do_rcv+0x8a/0x10e

This has already been fixed in 2.6.10-rc2.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
