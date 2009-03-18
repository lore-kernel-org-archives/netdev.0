From: David Miller <davem@davemloft.net>
Subject: Re: socket api problem: can't bind an ipv6 socket to ::ffff:0.0.0.0
Date: Wed, 18 Mar 2009 14:36:35 -0700 (PDT)
Message-ID: <20090318.143635.87275958.davem@davemloft.net>
References: <20090317.123146.210941276.davem@davemloft.net>
	<20090318091307.GB4799@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, felix-kernel@fefe.de, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46254
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751849AbZCRVgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 17:36:49 -0400
In-Reply-To: <20090318091307.GB4799@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 18 Mar 2009 09:13:07 +0000

> On 17-03-2009 20:31, David Miller wrote:
> > From: Brian Haley <brian.haley@hp.com>
> > Date: Tue, 17 Mar 2009 15:21:52 -0400
> > 
> >> Top-posting so others can see your off-list rant in full.  I see no
> >> reason to help you any further, even though I did have a patch that
> >> would change this behavior for you.  Good luck with your "biggest
> >> noncommercial Internet messaging infrastructure" in the world.
> > 
> > What a jerk.  Brian, don't help him any more, you were being
> > very reasonable in your email to him.  His response was way
> > out of line.
> 
> Do you mean he got that joke wrong? Otherwise I think he is right. We
> shouln't advise him how to do the things right, but, since what he
> wants looks like legal and acceptable elsewhere, try to do this the
> least invasive way.

First of all, no matter if we allow that kind of bind() he wants or
not, he cannot use it in his application unless he wants his
application to be useless of most people's machines for at least a
year.

That's why the "make Linux be compatible with X other systems" is
always a joke argument.  Application wise, one still has to be
compatible with all existing Linux systems which is a much larger
issue.

And yes we should advise people what is an appropriate way to
accomplish some task.  If we aren't the experts on such a topic,
then who the hell is?
