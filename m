From: "David S. Miller" <davem@redhat.com>
Subject: Re: [1/2] Use xfrm4_rcv in xfrm4_tunnel
Date: Thu, 19 Aug 2004 07:23:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040819072337.394abc67.davem@redhat.com>
References: <20040819113841.GA13872@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040819113841.GA13872@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 19 Aug 2004 21:38:41 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This is a trivial patch to use xfrm4_rcv in xfrm4_tunnel.  It doesn't
> need the extra argument provided by xfrm4_rcv_encap.

Applied.
