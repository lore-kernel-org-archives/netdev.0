From: James Morris <jmorris@redhat.com>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Sat, 4 Jun 2005 00:39:41 -0400 (EDT)
Message-ID: <Xine.LNX.4.44.0506040039190.11329-100000@thoron.boston.redhat.com>
References: <20050604004201.GB20471@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, "David S. Miller" <davem@davemloft.net>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050604004201.GB20471@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 4 Jun 2005, Herbert Xu wrote:

> So this is really a sort of bio_vec for crypto structures.  The objective
> here is to make the structure as compact as possible to allow users to
> allocate it on the stack most of the time.

Seems like a good idea to me.


- James
-- 
James Morris
<jmorris@redhat.com>
