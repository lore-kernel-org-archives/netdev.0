From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [ANNOUNCE] e1000 to e1000e migration of PCI Express devices
Date: Wed, 09 Apr 2008 21:38:22 +0200
Message-ID: <87ej9eom35.fsf@basil.nowhere.org>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu>
	<20080409190836.GA9276@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	NetDev <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Greg KH <greg@kroah.com>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out03.alice-dsl.net ([88.44.63.5]:15597 "EHLO
	smtp-out03.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048AbYDITit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2008 15:38:49 -0400
In-Reply-To: <20080409190836.GA9276@elte.hu> (Ingo Molnar's message of "Wed, 9 Apr 2008 21:08:36 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar <mingo@elte.hu> writes:
>
> except for the E1000=y && E1000E=m regression that bit me - that should 
> be solved and everyone will be happy.

Regarding getting bitten: could you please add E1000E to the x86 defconfigs?
That bit me an hour ago or so.

Thanks,

-Andi
