From: James Morris <jmorris@redhat.com>
Subject: Re: [INET] Add flags field to ip_tunnel_parm
Date: Tue, 14 Sep 2004 10:05:49 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0409141003500.24898-100000@thoron.boston.redhat.com>
References: <20040914121617.GA5652@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040914121617.GA5652@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 14 Sep 2004, Herbert Xu wrote:

> 3) Put it into some other file in net/ipv4 that's always built in.

I'd suggest net/ipv4/ip_tunnel.c



- James
-- 
James Morris
<jmorris@redhat.com>
