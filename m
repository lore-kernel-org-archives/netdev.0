From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PFKEY] spirange should be in host byte order
Date: Sat, 31 Jul 2004 23:51:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040731235126.40344324.davem@redhat.com>
References: <20040731100444.GA17201@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040731100444.GA17201@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 31 Jul 2004 20:04:44 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> So the conclusion is that we can and should change our PFKEY
> implementation to use host order for these fields.

I agree with this conclusion and have applied your patch.
Good thing we caught this now.

Thanks Herbert.
