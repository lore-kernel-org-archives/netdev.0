From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPSEC] fix ref counting in __xfrm4_bundle_create()
Date: Sat, 29 May 2004 12:46:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040529124633.713bd9f2.davem@redhat.com>
References: <20040529001450.GA647@gate.ebshome.net>
	<E1BTuV7-0002m2-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ebs@ebshome.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1BTuV7-0002m2-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 29 May 2004 13:27:13 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Well spotted.  Hopefully this should finally put an end to all these
> xfrm_state bug reports :)
> 
> However, can you see if the following patch fixes this problem as well?

I'm applying this patch.  If there is a fixup necessary, just let
me know.
