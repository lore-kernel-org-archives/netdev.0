From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: 2.6.31-rc5-git5: Reported regressions from 2.6.30
Date: Mon, 10 Aug 2009 09:30:43 -0500
Message-ID: <1249914643.4089.3.camel@mulgrave.site>
References: <AuPdDySr74O.A.5LC.Pj1fKB@chimera>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <AuPdDySr74O.A.5LC.Pj1fKB@chimera>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2009-08-09 at 22:36 +0200, Rafael J. Wysocki wrote:
> Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=13716
> Subject         : The AIC-7892P controller does not work any more
> Submitter       : Andrej Podzimek <andrej@podzimek.org>
> Date            : 2009-07-05 19:23 (36 days old)

This one sounds like an IRQ routing error, so probably ACPI, but we've
been totally unsuccessful at getting any further information out of the
submitter.  Use your own time judgement on this, but if he hasn't been
responding to you either for 36 days, I'd suggest closing this as
unresponsive.

James


