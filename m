From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [IPv4]: More fib_alias insertion fixes
Date: Mon, 27 Sep 2004 14:09:22 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16728.754.931720.194249@robur.slu.se>
References: <16727.65341.747293.986870@robur.slu.se>
	<E1CBuAe-00011H-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se (Robert Olsson), davem@davemloft.net, ja@ssi.bg,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CBuAe-00011H-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Herbert Xu writes:
 > Robert Olsson <Robert.Olsson@data.slu.se> wrote:
 > > 
 > > I'll guess struct fib_alias should not be defined in fib_hash.c to 
 > > support pluggable lookup algorithms.
 > 
 > Should one turn up then we can move it out :)

 Do. :-) Seems fib_find_alias should be moved out as well.

 Cheers.

						--ro
