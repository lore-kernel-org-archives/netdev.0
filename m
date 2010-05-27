From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Socket option to set congestion window
Date: Thu, 27 May 2010 00:28:51 -0700 (PDT)
Message-ID: <20100527.002851.02281005.davem@davemloft.net>
References: <20100526231512.GD2684@nuttenaction>
	<20100526.200443.232751390.davem@davemloft.net>
	<20100527070827.GB2728@nuttenaction>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, ycheng@google.com
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40850
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757023Ab0E0H2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 03:28:41 -0400
In-Reply-To: <20100527070827.GB2728@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Thu, 27 May 2010 09:08:27 +0200

> And by the way, the IETF (and our) paradigm is still to shift functionality to
> end hosts - not into network core. "The Rise of the stupid network" [1] is
> still a paradigm that is superior to the alternative where vendors put their
> proprietary algorithms into the network and change the behavior in a
> uncontrollable fashion.

Superior or not, it's simply never going to happen.  We are far beyond
being able to get to where we were before NAT'ing and shaping devices
started to get inserted everywhere on the network.

And I also don't see any of this stuff as fundamentally proprietary.

People want deep packet inspection, people want to control their user's
traffic.  And people, most importantly, are willing to pay for this.

Therefore, these elements will always be in the network.

Better to co-exist with them and use them to our advantage instead of
fantasizing about a utopia where they don't exist.
