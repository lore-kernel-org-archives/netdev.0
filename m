From: David Miller <davem@davemloft.net>
Subject: Re: Multiqueue and virtualization WAS(Re: [PATCH 3/3] NET: [SCHED]
 Qdisc changes and sch_rr added for multiqueue
Date: Fri, 29 Jun 2007 21:35:03 -0700 (PDT)
Message-ID: <20070629.213503.34601850.davem@davemloft.net>
References: <1183121670.5188.16.camel@localhost>
	<20070629.143102.88475921.davem@davemloft.net>
	<1183167053.5153.7.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46652
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751274AbXF3Een (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2007 00:34:43 -0400
In-Reply-To: <1183167053.5153.7.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Fri, 29 Jun 2007 21:30:53 -0400

> On Fri, 2007-29-06 at 14:31 -0700, David Miller wrote:
> > Maybe for the control node switch, yes, but not for the guest network
> > devices.
> 
> And that is precisely what i was talking about - and i am sure thats how
> the discussion with Patrick was.

Awesome, but let's concentrate on the client since I can actually
implement and test anything we come up with :-)
