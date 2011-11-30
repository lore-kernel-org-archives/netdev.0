From: Greg KH <greg@kroah.com>
Subject: Re: Bonding fixes for 2.6.33.y
Date: Wed, 30 Nov 2011 09:15:30 +0900
Message-ID: <20111130001530.GA9693@kroah.com>
References: <1322533200.26733.15.camel@bwh-desktop>
 <20111129224909.GA27909@kroah.com>
 <CA+5PVA6-tF5bPFwWQRKgit-m-BqQeK9TwsTTw4GkPWsNRettZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, stable@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org
To: Josh Boyer <jwboyer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:47105 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757063Ab1K3ASq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 19:18:46 -0500
Received: from compute6.internal (compute6.nyi.mail.srv.osa [10.202.2.46])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 35A432246A
	for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 19:18:46 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <CA+5PVA6-tF5bPFwWQRKgit-m-BqQeK9TwsTTw4GkPWsNRettZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2011 at 06:46:24PM -0500, Josh Boyer wrote:
> On Tue, Nov 29, 2011 at 5:49 PM, Greg KH <greg@kroah.com> wrote:
> > On Tue, Nov 29, 2011 at 02:19:59AM +0000, Ben Hutchings wrote:
> >> These have been applied to 2.6.32.y but are missing from 2.6.33.y:
> >
> > Perhaps because 2.6.33.y is not end-of-life and is not having any more
> > releases?
> 
> s/is not end-of-life/is now end-of-life/
> 
> ?

Yes, sorry, typo.
