From: "David S. Miller" <davem@redhat.com>
Subject: Re: Fw: [Bugme-new] [Bug 3200] New: linux-2.6.8-rc4-mm1:
 IPv6-in-IPv6 undefined references
Date: Sun, 15 Aug 2004 19:43:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040815194323.4f7b93eb.davem@redhat.com>
References: <20040814233108.51a04d33.akpm@osdl.org>
	<E1BwFe4-0007hy-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1BwFe4-0007hy-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 15 Aug 2004 17:41:36 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Andrew Morton <akpm@osdl.org> wrote:
> > 
> > As module:
> > 
> > **********
> > make[1]: `arch/i386/kernel/asm-offsets.s' is up to date.
> >  CHK     include/linux/compile.h
> > Kernel: arch/i386/boot/bzImage is ready
> >  Building modules, stage 2.
> >  MODPOST
> > *** Warning: "xfrm6_tunnel_deregister" [net/ipv6/ip6_tunnel.ko] undefined!
> > *** Warning: "xfrm6_tunnel_register" [net/ipv6/ip6_tunnel.ko] undefined!
> 
> This patch should fix it.

Applied.
