From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: rfc conformance fixes
Date: Tue, 21 Oct 2008 21:47:25 -0700 (PDT)
Message-ID: <20081021.214725.176087242.davem@davemloft.net>
References: <1224641327-11913-1-git-send-email-vladislav.yasevich@hp.com>
	<20081021.210557.126715235.davem@davemloft.net>
	<1224650698.6597.32.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jk@ozlabs.org
To: mbizon@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43159
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750746AbYJVErr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 00:47:47 -0400
In-Reply-To: <1224650698.6597.32.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maxime Bizon <mbizon@freebox.fr>
Date: Wed, 22 Oct 2008 06:44:58 +0200

> On Tue, 2008-10-21 at 21:05 -0700, David Miller wrote:
> 
> > Please CC: netdev on any and all patches you want applied.
> > 
> > That way it gets tracked properly at:
> > 
> > 	http://patchwork.ozlabs.org/project/netdev/list/
> 
> The feeder of patchwork does not seem to consider posts with subject
> like '[PATCH/RFC' '[PATCH,RFC]', yet I see '[RFC]' is ok.
> 
> Should I repost with another subject or RFC patches are not supposed to
> be in patchwork ?

Hmmm, that would be very strange if it were true.

Jeremy, patchwork doesn't try to interpret the subject line
at all does it?  My impression is that it simply looked for
patches in the email posting content and that's it.
