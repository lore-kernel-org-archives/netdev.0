From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NETLINK] Check netlink_insert in kernel_create
Date: Wed, 27 Oct 2004 21:45:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027214552.43125ae5.davem@davemloft.net>
References: <20041028030700.GA14181@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041028030700.GA14181@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 28 Oct 2004 13:07:00 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch checks the return value of netlink_insert() in
> netlink_kernel_create().  It could fail if someone loads
> the same module twice for instance.
> 
> Signed-off-by: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au> 

Applied, thanks.
