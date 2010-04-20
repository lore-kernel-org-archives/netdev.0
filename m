From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.34-rc5: Reported regressions from 2.6.33
Date: Tue, 20 Apr 2010 06:13:33 +0200
Message-ID: <201004200613.33696.rjw@sisk.pl>
References: <deuQKFRcc0B.A.3EG.BRSzLB@tosh> <20100419205723.8724338c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <20100419205723.8724338c.akpm@linux-foundation.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 20 April 2010, Andrew Morton wrote:
> On Tue, 20 Apr 2010 05:15:57 +0200 (CEST) "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=15812
> > Subject		: utsname.domainname not set in x86_32 processes (causing "YPBINDPROC_DOMAIN: domain not bound" errors)
> > Submitter	:  <adi@hexapodia.org>
> > Date		: 2010-04-19 21:28 (1 days old)
> 
> I merged hch's fix for this twelve seconds ago.

I updated the entry.
