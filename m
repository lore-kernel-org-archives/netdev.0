From: Ingo Molnar <mingo@elte.hu>
Subject: Re: oops/warning report for the week of November 26, 2008
Date: Thu, 27 Nov 2008 12:48:59 +0100
Message-ID: <20081127114859.GD29013@elte.hu>
References: <492DD792.6080302@linux.intel.com> <200811261605.43099.jbarnes@virtuousgeek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>, x86@kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Theodore Ts'o <tytso@mit.edu>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:60110 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751460AbYK0Ltc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Nov 2008 06:49:32 -0500
Content-Disposition: inline
In-Reply-To: <200811261605.43099.jbarnes@virtuousgeek.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Jesse Barnes <jbarnes@virtuousgeek.org> wrote:

> On Wednesday, November 26, 2008 3:11 pm Arjan van de Ven wrote:
> > Rank 2: pci_create_slot (warning)
> > 	Reported 603 times (639 total reports)
> > 	BIOS provided duplicated slot names, the PCI layer blindly passes to sysfs
> > 	This warning was last seen in version 2.6.27.5, and first seen in
> > 2.6.27-rc7-git1. More info:
> > http://www.kerneloops.org/searchweek.php?search=pci_create_slot
> 
> IIRC we fixed this one post-2.6.27.  I didn't send the patches back 
> to -stable because they were a bit big, but if someone were 
> sufficiently motiviated I'm sure the backport wouldn't be that 
> hard...

having the commit IDs mentioned here would be nice, should anyone feel 
motivated.

	Ingo
