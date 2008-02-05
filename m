From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan tag match
Date: Tue, 05 Feb 2008 03:20:40 -0800 (PST)
Message-ID: <20080205.032040.20578647.davem@davemloft.net>
References: <20080131210732.25f42884@extreme>
	<47A2AF6A.1060200@trash.net>
	<20080131215025.4ad118f2@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57746
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750890AbYBELUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 06:20:13 -0500
In-Reply-To: <20080131215025.4ad118f2@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 31 Jan 2008 21:50:25 -0800

> On Fri, 01 Feb 2008 06:34:34 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
> > Stephen Hemminger wrote:
> > > Provide a way to use tc filters on vlan tag even if tag is buried in
> > > skb due to hardware acceleration.
> > 
> > Looks reasonable. Would you like to add the same feature to the
> > flow classifier?
> 
> Yes, that would be good.

Did that patch get posted?  I didn't see it.
