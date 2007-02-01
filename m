From: Thomas Glanzmann <thomas@glanzmann.de>
Subject: Re: sky2 hangs
Date: Thu, 1 Feb 2007 20:19:01 +0100
Message-ID: <20070201191901.GP13130@cip.informatik.uni-erlangen.de>
References: <20070201185532.GL13130@cip.informatik.uni-erlangen.de> <20070201110552.5bf52c8f@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui03.informatik.uni-erlangen.de ([131.188.30.103]:57121 "EHLO
	faui03.informatik.uni-erlangen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1422954AbXBATTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Feb 2007 14:19:03 -0500
Content-Disposition: inline
In-Reply-To: <20070201110552.5bf52c8f@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Stephen,

> It was intentional in 2.6 to allow interfaces to be hot-removed.
> Remember with Internet protocols there is no hard binding (normally)
> between address and device and connections should not go down if link
> fails.

of course. That makes sense. I just wondered when the change in mind
happened. And actually I like this behaviour.

> > With that everything works. If somone is interested in my userland
> > watchdog, just send me an E-Mail.

> Hopefully, it won't be necessary for long.

So do I.

        Thomas
