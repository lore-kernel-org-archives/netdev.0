From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.7-rc3: unregister_netdevice: waiting for tun0 to become free. Usage count = 1
Date: Mon, 14 Jun 2004 11:50:13 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040614015013.GA11048@gondor.apana.org.au>
References: <20040613121514.6b3c1c8a.davem@redhat.com> <E1BZeW1-0008Ny-00@gondolin.me.apana.org.au> <20040613234142.GA32329@gondor.apana.org.au> <20040613183622.3a814506.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: schwab@suse.de, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040613183622.3a814506.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jun 13, 2004 at 06:36:22PM -0700, David S. Miller wrote:
> On Mon, 14 Jun 2004 09:41:42 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > BTW, it looks like I missed the original IPv4 idev patch to route.c
> > as well.  So could someone please tell me why it was needed in the
> > first place?
> 
> Because per-device ipv4/ipv6 statistics support is coming.
> It's necessary infrastructure.

Thanks.  Is there somewhere where I can look at the code that's
going to use this infrastructure?
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
