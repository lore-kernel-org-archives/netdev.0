From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [XFRM] Don't panic in xfrm_user_init
Date: Wed, 27 Oct 2004 21:46:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027214641.0a0f6d6c.davem@davemloft.net>
References: <20041028031640.GA14317@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041028031640.GA14317@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 28 Oct 2004 13:16:40 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Since xfrm_user can be built as a module it's best not to panic
> when something goes wrong in xfrm_user_init.  Call me a wimp for
> not fixing netlink_kernel_init's return value :)
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
