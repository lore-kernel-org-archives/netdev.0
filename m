From: Pavel Roskin <proski@gnu.org>
Subject: Re: Can someone please try...
Date: Tue, 16 Jan 2007 16:50:38 -0500
Message-ID: <1168984238.16115.9.camel@dv>
References: <200701161806.02780.mb@bu3sch.de> <1168972142.8299.11.camel@dv>
	 <200701162023.23919.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:47823 "EHLO
	fencepost.gnu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660AbXAPVum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 16:50:42 -0500
Received: from proski by fencepost.gnu.org with local (Exim 4.60)
	(envelope-from <proski@gnu.org>)
	id 1H6wBu-0001SK-2J
	for netdev@vger.kernel.org; Tue, 16 Jan 2007 16:50:02 -0500
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200701162023.23919.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-01-16 at 20:23 +0100, Michael Buesch wrote:

> A patch for that is already upstream.

I don't see it.  It's not in your tree yet.

> It's surprising that it doesn't happen for me, though.
> Neiter on PPC, nor on i386.

It did happen for me on i386, as well as on x86_64.  The dump was for
x86_64, as evidenced by the register size.  Maybe you have less
debugging options enabled?

> Patch was
> [PATCH] bcm43xx-d80211: Fix DMA TX skb doublefree

Even with this hint, I cannot spot the bug immediately, so it would be
great if you sync the public repository soon.

-- 
Regards,
Pavel Roskin


