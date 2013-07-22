From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] ip: initialize hash list
Date: Mon, 22 Jul 2013 08:31:09 -0700
Message-ID: <1374507069.2061.48.camel@joe-AO722>
References: <20130720102657.768a11ea@nehalam.linuxnetplumber.net>
	 <1374342380.1940.2.camel@joe-AO722>
	 <20130722075245.70310bfa@nehalam.linuxnetplumber.net>
	 <1374505616.2061.40.camel@joe-AO722>
	 <1374506158.4990.11.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:55000 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755908Ab3GVPbK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jul 2013 11:31:10 -0400
In-Reply-To: <1374506158.4990.11.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-22 at 08:15 -0700, Eric Dumazet wrote:
> On Mon, 2013-07-22 at 08:06 -0700, Joe Perches wrote:
> > On Mon, 2013-07-22 at 07:52 -0700, Stephen Hemminger wrote:
> > > On Sat, 20 Jul 2013 10:46:20 -0700
> > > Joe Perches <joe@perches.com> wrote:
> > []
> > > > Are you doing to do just this one or submit a series?
> > > 
> > > Hadn't planned on fixing more than one. And would not go outside code
> > > that I actually use.
> > 
> > What a pity.
> > 
> > I think if you identify what you believe is a
> > trivial defect in your own code, it's both
> > polite and social to fix similar defects in
> > other code too.
> 
> Joe, I find this quite misplaced.

Our opinions differ then.

What's "misplaced" about suggesting that  a
person that identifies and submits a patch
for a code form viewed as sub-optimal could
fix the other instances of that code form?

> So far, there is no bug.

I did not even suggest there was a bug.
I wrote "trivial defect".

> What about fixing real bugs instead ?

That'd be good too, with the caveat that
those "real bugs" can take a rather more
intensive effort to identify, isolate and
correct without introducing other defects.
