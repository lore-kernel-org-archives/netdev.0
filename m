From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: pskb change in dst->output
Date: Thu, 8 Jul 2004 11:11:00 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040708011100.GA31600@gondor.apana.org.au>
References: <20040707171759.025eb13b.davem@redhat.com> <Xine.LNX.4.44.0407072104170.29077-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0407072104170.29077-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 07, 2004 at 09:05:11PM -0400, James Morris wrote:
> 
> Btw, this should also lead to a performance increase for Netfilter, 
> although I haven't measured it.

I'm totally happy with the netfilter part of the change.

I'm just a bit unsure whether the pskb change is needed in dst_output().

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
