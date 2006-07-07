From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Action API fixes
Date: Thu, 06 Jul 2006 23:56:45 -0700 (PDT)
Message-ID: <20060706.235645.30161277.davem@davemloft.net>
References: <1152187428.5103.6.camel@jzny2>
	<1152188854.5103.17.camel@jzny2>
	<20060706124539.GZ14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:62390
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751213AbWGGG43 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 02:56:29 -0400
To: tgraf@suug.ch
In-Reply-To: <20060706124539.GZ14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 6 Jul 2006 14:45:39 +0200

> * jamal <hadi@cyberus.ca> 2006-07-06 08:27
> > 
> > The proper patch is attached as a replacement for 
> > "[PATCH 3/3] [PKT_SCHED]: Fix error handling while dumping action"
> > from Thomas. 
> > If you have already submitted it, then i will send a patch against it.
> 
> I don't understand why you're picky about this but if you really
> want to then do it properly and remove the now unused err variable,
> don't leave obscure code behind again.

I don't either, I think Thomas's patch was correct and that's
why his is the one I applied.

Sometimes it is necessary for one to buffer their resistence to the
way someone fixes you code and just let it go.  Otherwise people
won't even bother trying to fix those bugs.

People who do the work make the rules, that is my supreme motto.  And
here that is Thomas, and therefore I will favor in the direction of
his judgement.
