From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Openswan Users] Invalid argument NULL
Date: Mon, 16 Aug 2004 18:03:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040816180350.780e4912.davem@redhat.com>
References: <BD428BAA.4BBE%jiva@ixiacom.com>
	<E1BwINn-0000ZX-00@gondolin.me.apana.org.au>
	<20040815112548.GA2864@gondor.apana.org.au>
	<20040815195313.31bacf13.davem@redhat.com>
	<20040817004141.GA18789@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jiva@ixiacom.com, users@lists.openswan.org, dev@lists.openswan.org,
        kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040817004141.GA18789@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 17 Aug 2004 10:41:41 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> So maybe we should keep the numbers?

If we take out the names, won't this break xfrm_user apps
that currently can receive them?
