From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: 27 Sep 2004 08:41:09 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096288869.1073.31.camel@jzny.localdomain>
References: <20040920025802.GA11567@gondor.apana.org.au>
	 <1095683660.1047.254.camel@jzny.localdomain> <414F1E12.6010808@eurodev.net>
	 <20040922000503.GA13218@gondor.apana.org.au> <4150E7E5.2000001@eurodev.net>
	 <1095821624.1045.6.camel@jzny.localdomain>
	 <20040922034634.GA14928@gondor.apana.org.au>
	 <1095852956.1048.47.camel@jzny.localdomain>
	 <20040923120520.GA32624@gondor.apana.org.au>
	 <1095994597.1045.26.camel@jzny.localdomain>
	 <20040924032002.GA6384@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040924032002.GA6384@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-09-23 at 23:20, Herbert Xu wrote:
> On Thu, Sep 23, 2004 at 10:56:37PM -0400, jamal wrote:
> >
> > > What's wrong with the default sizes? If you decrease it far enough
> > > of course it's going to overflow.
> > 
> > The idea is to reproduce the overun ;->
> 
> OK, I've just tried 4096 and nothing:

Try harder! ;-> 
Ok, I will go and lookup my test machine and get back with an exact test
case (problem is whenever i have time to scan my emails i am at least 30
minutes away from that box).

cheers,
jamal
