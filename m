From: jamal <hadi@cyberus.ca>
Subject: Re: [IPv4] Kill remnant of ip_nat_dumb
Date: 22 Sep 2004 08:10:39 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095855039.1045.67.camel@jzny.localdomain>
References: <20040922040155.GA19302@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040922040155.GA19302@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Geez, I missed that we killed static NAT too. Whats wrong with it?
I know at least two users of this - did we ask or 
is posting on netdev == ask?

cheers,
jamal

On Wed, 2004-09-22 at 00:01, Herbert Xu wrote:
> Hi Dave:
> 
> This line in net/ipv4/Makefile was left behind when the rest of the
> dumb NAT option was taken out.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Cheers,
