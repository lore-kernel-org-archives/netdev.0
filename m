From: jamal <hadi@cyberus.ca>
Subject: On DaveMs congestion control algorithm WAS(Re: [PATCH] Improve
	behaviour of Netlink Sockets
Date: 28 Sep 2004 08:39:49 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096375188.8663.226.camel@jzny.localdomain>
References: <1096289189.1075.37.camel@jzny.localdomain>
	 <20040927213607.GD7243@gondor.apana.org.au>
	 <1096339407.8660.33.camel@jzny.localdomain>
	 <20040928024614.GA9911@gondor.apana.org.au>
	 <1096340772.8659.51.camel@jzny.localdomain>
	 <20040928032321.GB10116@gondor.apana.org.au>
	 <1096343125.8661.96.camel@jzny.localdomain>
	 <20040928035921.GA10675@gondor.apana.org.au>
	 <1096367787.8662.146.camel@jzny.localdomain>
	 <20040928111159.GA18421@gondor.apana.org.au>
	 <20040928121647.GA21121@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040928121647.GA21121@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-09-28 at 08:16, Herbert Xu wrote:
> On Tue, Sep 28, 2004 at 09:11:59PM +1000, herbert wrote:
> >
> > > BTW, Davem gets away with this congestion control alg all the time.
> > > Heck i think his sanity survives because of it - I bet you hes got this
> > > thread under congestion controlled right now;->
> > 
> > Yep, his overrun flag sure is set :)
> 
> Now if he puts his mailing admin hat on and tells us to shut up, that
> would be congestion control :)

Hed have to go and read all the emails first ;-> i.e the overrun flag
requires that you reread state.

cheers,
jamal
