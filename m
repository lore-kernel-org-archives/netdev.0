From: James Morris <jmorris@redhat.com>
Subject: Re: [RTNETLINK] Convert RTM_* to enum
Date: Tue, 14 Sep 2004 23:38:21 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0409142337130.28280-100000@thoron.boston.redhat.com>
References: <20040915020942.GA32721@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040915020942.GA32721@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Sep 2004, Herbert Xu wrote:

> I decided to bite the bullet and use netlink for the tunnel operations.
> Before I do that, here is a patch to convert the RTM_* constants to an
> enum.

Having the enums as well as the defines is messy, I wonder if it's really
worth it.


- James
-- 
James Morris
<jmorris@redhat.com>
