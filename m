From: "David S. Miller" <davem@redhat.com>
Subject: Re: [ESP] Only one algorithm is required
Date: Sun, 15 Aug 2004 19:54:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040815195425.72332d01.davem@redhat.com>
References: <20040814105245.GA20646@gondor.apana.org.au>
	<Xine.LNX.4.44.0408141012510.26617-100000@dhcp83-76.boston.redhat.com>
	<20040814192412.GA24399@gondor.apana.org.au>
	<20040814195639.GA25009@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040814195639.GA25009@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 15 Aug 2004 05:56:39 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> The way to get null algorithms through is to attach a non-null algorithm
> with the name set to cipher_null/digest_null.
> 
> However, we should fix IPv6 to allow null authentication algorithms.

Applied.
