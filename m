From: "David S. Miller" <davem@redhat.com>
Subject: Re: [XFRM] Handle device down/unregister events
Date: Sat, 29 Nov 2003 20:27:55 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031129202755.292602a6.davem@redhat.com>
References: <20031126044355.GA18805@gondor.apana.org.au>
	<20031125222059.6730f242.davem@redhat.com>
	<20031127105907.GA13047@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20031127105907.GA13047@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 Nov 2003 21:59:07 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Here is an updated patch that checks whether a dst is still valid
> before adding it to a bundle.

Applied.

I had already applied your previous patch, so it would have
been nice to have a relative patch, please do this next time.

Thanks.
