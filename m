From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Known problems with TCP window size on 2.6.7?
Date: Wed, 27 Oct 2004 22:18:30 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CMml4-0001Cm-00@gondolin.me.apana.org.au>
References: <20041027110617.GA28757@vana.vc.cvut.cz>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: vandrove@vc.cvut.cz (Petr Vandrovec)
In-Reply-To: <20041027110617.GA28757@vana.vc.cvut.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Petr Vandrovec <vandrove@vc.cvut.cz> wrote:
>   are there some known problems with 2.6.7 and TCP window growing up over limits?  

No.

> usermap is running 2.6.7-bk1, regata1 is running some AIX5.

You need to show us the SYN packets as well.  More importantly,
you need to show us dumps on both sides of the connection since
there may be a router/firewall in the middle that's fiddling with
the bits.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
