From: "David S. Miller" <davem@davemloft.net>
Subject: Re: On DaveMs congestion control algorithm WAS(Re: [PATCH] Improve
 behaviour of Netlink Sockets
Date: Tue, 28 Sep 2004 11:24:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928112432.238f433c.davem@davemloft.net>
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
	<1096375188.8663.226.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, pablo@eurodev.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1096375188.8663.226.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 28 Sep 2004 08:39:49 -0400
jamal <hadi@cyberus.ca> wrote:

> On Tue, 2004-09-28 at 08:16, Herbert Xu wrote:
> > On Tue, Sep 28, 2004 at 09:11:59PM +1000, herbert wrote:
> > >
> > > > BTW, Davem gets away with this congestion control alg all the time.
> > > > Heck i think his sanity survives because of it - I bet you hes got this
> > > > thread under congestion controlled right now;->
> > > 
> > > Yep, his overrun flag sure is set :)
> > 
> > Now if he puts his mailing admin hat on and tells us to shut up, that
> > would be congestion control :)
> 
> Hed have to go and read all the emails first ;-> i.e the overrun flag
> requires that you reread state.

When I see two guys going at it like you too, I just wait
for the dust to settle in the form of a patch and then I
reread the thread as if it were the latest drama show on TV
:-)
