From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] PPPoE: race between interface going down and
 release()
Date: Fri, 20 Apr 2007 17:22:30 -0700 (PDT)
Message-ID: <20070420.172230.78015963.davem@davemloft.net>
References: <1173667016.24373.36.camel@kdsk1.austin.ibm.com>
	<20070420.162756.78644819.davem@davemloft.net>
	<20070420234405.GB25618@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mostrows@earthlink.net, netdev@vger.kernel.org
To: florz@florz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56381
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753915AbXDUAW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 20:22:27 -0400
In-Reply-To: <20070420234405.GB25618@florz.florz.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Zumbiehl <florz@florz.de>
Date: Sat, 21 Apr 2007 01:44:05 +0200

> > This patch doesn't apply becuase in the actual pppoe.c code:
> 
> [...]
> 
> > So I'm having trouble figuring out what tree you generated
> > that patch against :-)  Perhaps there was an earlier patch
> > I missed or something.
> > 
> > But I won't second guess and leave it to you to let me know
> > what I should actually apply.
> 
> That one was against my first try of a fix. So, either you apply that
> one first and then remove it again by applying that patch ;-) - or just
> ignore those four patches completely and apply
> <11737949753580-git-send-email-mostrows@earthlink.net> ff instead.

I figured out what happened and put in the 4-patch set later in my
backlog, thanks!
