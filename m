From: Greg KH <greg@kroah.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at
 000000000000002c
Date: Fri, 2 Dec 2011 10:53:12 -0800
Message-ID: <20111202185312.GA13166@kroah.com>
References: <4ED86B79.4060506@profihost.ag>
 <20111202.011739.1018700331407530740.davem@davemloft.net>
 <4ED87BE9.20104@profihost.ag>
 <20111202.123435.740930342839308437.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	jwboyer@gmail.com, hch@infradead.org, netdev@vger.kernel.org,
	david@fromorbit.com, stable@vger.kernel.org
To: s.priebe@profihost.ag
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4.smtp.messagingengine.com ([66.111.4.28]:36756 "EHLO
	out4.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751459Ab1LBTAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 14:00:35 -0500
Received: from compute5.internal (compute5.nyi.mail.srv.osa [10.202.2.45])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id C962C212F0
	for <netdev@vger.kernel.org>; Fri,  2 Dec 2011 14:00:34 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <20111202.123435.740930342839308437.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 02, 2011 at 12:34:35PM -0500, David Miller wrote:
> From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
> Date: Fri, 02 Dec 2011 08:19:05 +0100
> 
> > Am 02.12.2011 07:17, schrieb David Miller:
> >> From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
> >> Date: Fri, 02 Dec 2011 07:08:57 +0100
> >> 
> >>> So can someone please send them to greg => stable@ so we can get them
> >>> into 3.0.X longterm stable.
> >> 
> >> I'll do it, these things just take care and time.
> > 
> > Thanks! Could you please CC me?
> 
> Sorry, I'm not going to do that, the I'd have to do it for anyone who asks
> me to and that's not reasonable.

Stefan, the stable@vger.kernel.org list is public, you are free to
subscribe it if you are curious as to when patches are both submitted to
it, and when they are applied to the trees.

greg k-h
