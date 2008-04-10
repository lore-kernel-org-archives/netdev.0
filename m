From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [patch] e1000=y && e1000e=m regression fix (was: Re: [regression] e1000e broke e1000)
Date: Thu, 10 Apr 2008 11:57:15 +0200
Message-ID: <m34paaav7o.fsf@maximus.localdomain>
References: <20080408083606.GA20863@elte.hu> <47FB9ABB.9080403@intel.com>
	<20080408183921.GA20803@elte.hu>
	<20080408193245.GG11962@parisc-linux.org>
	<20080408195123.GA28148@elte.hu> <47FBCE00.2020309@garzik.org>
	<20080408200652.GC28148@elte.hu> <47FBD34A.6080508@garzik.org>
	<20080408203314.GA28952@elte.hu> <47FBDBE9.9040700@garzik.org>
	<47FBDBE9.9040700@garzik.org> <20080409193850.GA11763@elte.hu>
	<200804092249.23111.elendil@planet.nl>
	<m363uqwpds.fsf@maximus.localdomain>
	<alpine.LFD.1.00.0804091838330.3143@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frans Pop <elendil@planet.nl>, Ingo Molnar <mingo@elte.hu>,
	jeff@garzik.org, matthew@wil.cx, auke-jan.h.kok@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	linux-pci@atrey.karlin.mff.cuni.cz, akpm@linux-foundation.org,
	davem@davemloft.net, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, bruce.w.allan@intel.com, greg@kroah.com,
	arjan@linux.intel.com, rjw@sisk.pl
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ZSM1387.piap.pl ([195.187.100.11]:51726 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752171AbYDJJ5R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 05:57:17 -0400
In-Reply-To: <alpine.LFD.1.00.0804091838330.3143@woody.linux-foundation.org> (Linus Torvalds's message of "Wed\, 9 Apr 2008 18\:40\:24 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linus Torvalds <torvalds@linux-foundation.org> writes:

>> Nope, udev with normal distro config will load e1000e just fine.
>
> Not for us that don't compile modules at all, or only modules for the 
> devices we actually have.

That would work, too.
-- 
Krzysztof Halasa
