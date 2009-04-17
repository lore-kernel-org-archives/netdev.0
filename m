From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.30-rc2-git2: Reported regressions from 2.6.29
Date: Fri, 17 Apr 2009 23:31:05 +0200
Message-ID: <200904172331.06910.rjw@sisk.pl>
References: <EJaiQ4Wfaz.A.3YG.4v85JB@chimera> <alpine.LFD.2.00.0904161742140.4042@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761730AbZDQVbd@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.0904161742140.4042@localhost.localdomain>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 17 April 2009, Linus Torvalds wrote:
> 
> On Thu, 16 Apr 2009, Rafael J. Wysocki wrote:
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13098
> > Subject		: 2.6.29-git12 breaks vga=0x0f07 on MSI/Intel GPU
> > Submitter	: Andi Kleen <andi@firstfloor.org>
> > Date		: 2009-04-06 01:14 (11 days old)
> > References	: http://lkml.org/lkml/2009/4/5/200
> > Handled-By	: H. Peter Anvin <hpa@zytor.com>
> 
> I think this got fixed already. The VGA moresettign was reverted back to 
> the old order.

Closed.

> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13044
> > Subject		: 2.6.30-rc1 can't find the root fs
> > Submitter	: Heinz Diehl <htd@fancy-poultry.org>
> > Date		: 2009-04-08 13:35 (9 days old)
> 
> This was one of the async things that got fixed by just waiting for module 
> async work to finish.

Closed.

Thanks,
Rafael
