From: Albert Hopkins <kernel@marduk.letterboxes.org>
Subject: Re: [1/6] 2.6.21-rc2: known regressions
Date: Wed, 07 Mar 2007 16:17:05 -0600
Message-ID: <1173305825.6462.4.camel@blackwidow.nbk>
References: <Pine.LNX.4.64.0702272105220.12485@woody.linux-foundation.org>
	 <20070305015031.GF3441@stusta.de>  <45EE9CBD.9040807@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, Ayaz Abdulla <aabdulla@nvidia.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Sid Boyce <g3vbv@blueyonder.co.uk>,
	Pavel Machek <pavel@ucw.cz>,
	Marcel Holtmann <marcel@holtmann.org>, linux-pm@lists.osdl.org,
	maxk@qualcomm.com, bluez-devel@lists.sf.net,
	Mark Lord <lkml@rtr.ca>, Greg KH <greg@kroah.com>,
	Matt Mackall <mpm@selenic.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5.smtp.messagingengine.com ([66.111.4.29]:58628 "EHLO
	out5.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S2992478AbXCGWRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 17:17:15 -0500
In-Reply-To: <45EE9CBD.9040807@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-03-07 at 06:06 -0500, Jeff Garzik wrote:
> Adrian Bunk wrote:
> > Subject    : forcedeth: skb_over_panic
> > References : http://bugzilla.kernel.org/show_bug.cgi?id=8058
> > Submitter  : Albert Hopkins <kernel@marduk.letterboxes.org>
> > Status     : unknown
> 
> 
> I think this is fixed by the recent forcedeth 3-patch patchset?  Can 
> Albert or others confirm?
> 
> 	Jeff
> 

I'll reflect this in th bug report, but I recently tried the forcedeth
driver in 2.6.21-rc3 and still get an oops.

--
Albert W. Hopkins

