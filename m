From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 19:46:49 +0000
Message-ID: <20071113194649.GE1356@flint.arm.linux.org.uk>
References: <4739AFE0.20705@rtr.ca> <20071113164650.GA28493@elte.hu> <4739E3D0.10201@rtr.ca> <20071113181228.GF4250@stusta.de> <4739EA83.5040006@rtr.ca> <20071113183605.GG4250@stusta.de> <4739F12E.5020807@rtr.ca> <20071113190428.GH4250@stusta.de> <4739F739.5040708@rtr.ca> <20071113193035.GI4250@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Lord <liml@rtr.ca>, alsa-devel@alsa-project.org,
	netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	linux-kernel@vger.kernel.org, protasnb@gmail.com,
	David Miller <davem@davemloft.net>, linux-ide@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	linux-input@atrey.karlin.mff.cuni.cz, Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:39306 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758847AbXKMTrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 14:47:19 -0500
Content-Disposition: inline
In-Reply-To: <20071113193035.GI4250@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2007 at 08:30:35PM +0100, Adrian Bunk wrote:
> There is this silly limit that noone can work more than 168 hours per 
> week on the Linux kernel, and some kernel developers seem to take the 
> liberty of spending even less time on kernel development...

That limit of 168 hours applies all around the world to everyone.
Moreover, not all kernel developers are employed to hack on the
kernel for 168 hours a week.

For me, personally, that figure is in reality about 24 hours a
week.  Yes, just 24.  The rest of the time (like *now*) is time I'm
volunteering because I happen to be reading my email...

... and happen to be wasting replying to discussions like this rather
than reading that message which has just arrived on the ARM kernel
mailing list from someone having problems using copy_from_user()
with a kernel pointer.

So, please, stop this idea that somehow kernel developers can
somehow spend infinite amounts of time solving lots and lots of
bugs.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:
