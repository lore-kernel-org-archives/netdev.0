From: jamal <hadi@cyberus.ca>
Subject: Re: Multiqueue and virtualization WAS(Re: [PATCH 3/3] NET: [SCHED]
	Qdisc changes and sch_rr added for multiqueue
Date: Fri, 29 Jun 2007 21:30:53 -0400
Message-ID: <1183167053.5153.7.camel@localhost>
References: <1183117415.5156.61.camel@localhost>
	 <4684F41B.9080309@trash.net> <1183121670.5188.16.camel@localhost>
	 <20070629.143102.88475921.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.251]:21192 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500AbXF3Ba6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 21:30:58 -0400
Received: by ag-out-0708.google.com with SMTP id 35so931503aga
        for <netdev@vger.kernel.org>; Fri, 29 Jun 2007 18:30:58 -0700 (PDT)
In-Reply-To: <20070629.143102.88475921.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-29-06 at 14:31 -0700, David Miller wrote:
> This conversation begins to go into a pointless direction already, as
> I feared it would.
> 
> Nobody is going to configure bridges, classification, tc, and all of
> this other crap just for a simple virtualized guest networking device.
> 
> It's a confined and well defined case that doesn't need any of that.
> You've got to be fucking kidding me if you think I'm going to go
> through the bridging code and all of that layering instead of my
> hash demux on transmit which is 4 or 5 lines of C code at best.
> 
> Such a suggestion is beyond stupid.
> 

Ok, calm down - will you please? 
If you are soliciting for opinions, then you should be expecting all
sorts of answers, otherwise why bother posting. If you think you are
misunderstood just clarify. Otherwise you are being totaly unreasonable.

> Maybe for the control node switch, yes, but not for the guest network
> devices.

And that is precisely what i was talking about - and i am sure thats how
the discussion with Patrick was.

cheers,
jamal

