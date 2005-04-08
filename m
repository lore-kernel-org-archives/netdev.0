From: Christoph Lameter <christoph@lameter.com>
Subject: Re: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Fri, 8 Apr 2005 08:05:00 -0700 (PDT)
Message-ID: <Pine.LNX.4.58.0504080803520.22345@graphe.net>
References: <Pine.LNX.4.58.0504051925250.21486@graphe.net>
 <E1DJ5y2-0003rF-00@gondolin.me.apana.org.au> <20050406111721.3ac67605.davem@davemloft.net>
 <20050407110724.GA8760@gondor.apana.org.au> <Pine.LNX.4.58.0504070842420.29731@graphe.net>
 <20050407212504.GA4939@gondor.apana.org.au> <Pine.LNX.4.58.0504072221190.11242@graphe.net>
 <20050408054831.GA569@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050408054831.GA569@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 8 Apr 2005, Herbert Xu wrote:

> This is wrong.  The barrier needs to be after the atomic_read.
> Please see my patch to Dave.

Ok. How does one get onto the netdev list? The personal cc's of my mail
to you also always bounces with admin prohibition.
