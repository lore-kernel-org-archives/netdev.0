From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: 2.6.12-rc4-mm[12] - ULOG problem
Date: Thu, 19 May 2005 14:49:46 +1000
Message-ID: <E1DYcyg-0005fP-00@gondolin.me.apana.org.au>
References: <20050518202458.55a63d37.akpm@osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org (Andrew Morton)
In-Reply-To: <20050518202458.55a63d37.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
> 
> This is the second report of this happening.
> 
> FATAL: Error inserting ipt_ULOG (/lib/modules/2.6.12-rc4-mm1-2/kernel/net/ipv4/netfilter/ipt_ULOG.ko): Cannot allocate memory

This probably means that someone has stolen the NETLINK_NFLOG id.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
