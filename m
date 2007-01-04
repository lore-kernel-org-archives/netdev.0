From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] sungem: PHY updates & pause fixes
Date: Fri, 05 Jan 2007 08:15:31 +1100
Message-ID: <1167945331.5273.8.camel@localhost.localdomain>
References: <1167802802.6165.129.camel@localhost.localdomain>
	 <20070103.185521.64808473.davem@davemloft.net>
	 <5cac192f0701041206x421824e9oedcd6a8e5c814f8b@mail.gmail.com>
	 <20070104.122716.58455250.davem@davemloft.net>
	 <5cac192f0701041257i61e85239y638637a615d421fd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:49888 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030191AbXADVPj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jan 2007 16:15:39 -0500
To: Eric Lemoine <eric.lemoine@gmail.com>
In-Reply-To: <5cac192f0701041257i61e85239y638637a615d421fd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-01-04 at 21:57 +0100, Eric Lemoine wrote:
> On 1/4/07, David Miller <davem@davemloft.net> wrote:
> > From: "Eric Lemoine" <eric.lemoine@gmail.com>
> > Date: Thu, 4 Jan 2007 21:06:48 +0100
> >
> > > On 1/4/07, David Miller <davem@davemloft.net> wrote:
> > > > I've applied that patch, thanks.
> > >
> > > David, I suppose you've applied the locking patch as well...
> >
> > No, not yet.
> >
> > Your locking patches are definitely 2.6.21 material, but
> > Ben's changes fix PAUSE handling bugs so I want to
> > put his patch into 2.6.20
> >
> > I'll put your locking bits into 2.6.21, don't worry :-)
> 
> I'm relieved now :-)
> 
> I was asking because Ben said his patch applied on top of mine.

Well, I did it with yours applied already but it seems like they don't
really conflict so they can be applied pretty much in any order.

Ben.


