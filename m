From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Openswan Users] Invalid argument NULL
Date: Sun, 15 Aug 2004 19:53:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040815195313.31bacf13.davem@redhat.com>
References: <BD428BAA.4BBE%jiva@ixiacom.com>
	<E1BwINn-0000ZX-00@gondolin.me.apana.org.au>
	<20040815112548.GA2864@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jiva@ixiacom.com, users@lists.openswan.org, dev@lists.openswan.org,
        kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040815112548.GA2864@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 15 Aug 2004 21:25:48 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> In any case, here is a really ugly patch to fill in those values for
> xfrm_user.  Please let me know of any clean-ups or better ways of doing
> this.

I've applied this for now.  There is a lot of duplication around
the xfrm structures of this kind of information.

Thanks.
