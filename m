From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Fri, 28 Jul 2006 09:17:25 +0400
Message-ID: <20060728051723.GA11210@2ka.mipt.ru>
References: <20060718081625.GA13830@2ka.mipt.ru> <20060718230121.GA31474@ms2.inr.ac.ru> <1153966671.6904.71.camel@localhost.localdomain> <20060726.221708.123400049.davem@davemloft.net> <1153979173.6904.100.camel@localhost.localdomain> <20060727163335.GA12944@ms2.inr.ac.ru> <20060727165121.GA6637@2ka.mipt.ru> <20060727205651.GA29953@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:64643 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932577AbWG1FRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 01:17:46 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20060727205651.GA29953@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2006 at 12:56:51AM +0400, Alexey Kuznetsov (kuznet@ms2.inr.ac.ru) wrote:
> Hello!
> 
> > kernel thread takes 100% cpu (with preemption
> 
> Preemption, you tell... :-)
> 
> I begged you to spend 1 minute of your time to press ^Z. Did you?

What would you expect from non-preemptible kernel? Hard lockup, no acks,
no soft irqs. So this case still does not differ from process' context
processing.

And after several minutes I pressed hardware reset button...

> Alexey

-- 
	Evgeniy Polyakov
