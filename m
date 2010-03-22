From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.34-rc2: Reported regressions from 2.6.33
Date: Mon, 22 Mar 2010 22:20:41 +0100
Message-ID: <201003222220.41347.rjw@sisk.pl>
References: <M9dVcHY7TxH.A.2GC.ZBopLB@chimera> <alpine.LFD.2.00.1003221012270.18017@i5.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Alex Villacis Lasso <avillaci@ceibo.fiec.espol.edu.ec>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1003221012270.18017@i5.linux-foundation.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 22 March 2010, Linus Torvalds wrote:
> 
> On Sun, 21 Mar 2010, Rafael J. Wysocki wrote:
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=15495
> > Subject		: Flood of SELinux denials on polkitd
> > Submitter	: Alex Villacis Lasso <avillaci@ceibo.fiec.espol.edu.ec>
> > Date		: 2010-03-09 16:47 (13 days old)
> 
> Fixed by commit 3836a03d978e68b0ae00d3589089343c998cd4ff ("anon_inodes: 
> mark the anon inode private"), I'm pretty sure.

Thanks, closed.

Rafael
