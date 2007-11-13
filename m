From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 23:29:54 +0000
Message-ID: <20071113232954.GK1356@flint.arm.linux.org.uk>
References: <20071113034916.2556edd7.akpm@linux-foundation.org> <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113.043207.44732743.davem@davemloft.net> <20071113193219.GC1356@flint.arm.linux.org.uk> <20071113201319.GL4250@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	alsa-devel@alsa-project.org, netdev@vger.kernel.org,
	linux-pcmcia@lists.infradead.org, linux-kernel@vger.kernel.org,
	protasnb@gmail.com, linux-ide@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	linux-input@atrey.karlin.mff.cuni.cz
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:48843 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754312AbXKMXay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 18:30:54 -0500
Content-Disposition: inline
In-Reply-To: <20071113201319.GL4250@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2007 at 09:13:19PM +0100, Adrian Bunk wrote:
> On Tue, Nov 13, 2007 at 07:32:19PM +0000, Russell King wrote:
> >...
> > There's another issue I want to raise concerning bugzilla.  We have the
> > classic case of "not enough people reading bugzilla bugs" - which is one
> > of the biggest problems with bugzilla.  Virtually no one in the ARM
> > community looks for ARM bugs in bugzilla.
> > 
> > Let's not forget that it would be a waste of time for people to manually
> > check bugzilla for ARM bugs.  There's soo few people reporting ARM bugs
> > into bugzilla that a weekly manual check by every maintainer would just
> > return the same old boring results for months and months at a time.
> >...
> 
> What about having all ARM bugs in Bugzilla by default assigned to 
> linux-arm-kernel@lists.arm.linux.org.uk? [1]

That would also work, probably much better than setting up yet another
list.

My experience of trying to get mbligh to do this when I stopped looking
after PCMCIA stuff was *extremely* painful.  Wonder if it's become any
easier of late?

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:
