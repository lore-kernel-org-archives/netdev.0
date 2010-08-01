From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: 2.6.35-rc6-git6: Reported regressions from 2.6.34
Date: Sun, 1 Aug 2010 23:37:09 +0200
Message-ID: <201008012337.09961.rjw@sisk.pl>
References: <2dWFdr9kTFM.A.P0D.spXVMB@chimera> <AANLkTimcH7+Bq1UEbaSU7SQpzArPgmSLegiqE13V8=CF@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jens Axboe <jaxboe-5c4llco8/ftWk0Htik3J/w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTimcH7+Bq1UEbaSU7SQpzArPgmSLegiqE13V8=CF-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday, August 01, 2010, Linus Torvalds wrote:
> On Sun, Aug 1, 2010 at 6:46 AM, Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org> wrote:
...
> 
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=16369
> > Subject         : Yet another 2.6.35 regression (AGP)?
> > Submitter       : Woody Suwalski <terraluna977-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date            : 2010-07-09 14:21 (24 days old)
> > Message-ID      : <4C373084.8000503-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > References      : http://marc.info/?l=linux-kernel&m=127868797119254&w=2
> 
> Should hopefully be fixed by commit e7b96f28c58c ("agp/intel: Use the
> correct mask to detect i830 aperture size.")

Closed.

> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=16365
> > Subject         : kernel BUG at fs/btrfs/extent-tree.c:1353
> > Submitter       : Johannes Hirte <johannes.hirte-3kN+8DYepx7zMJDuovMtMLNAH6kLmebB@public.gmane.org>
> > Date            : 2010-07-08 14:27 (25 days old)
> > Message-ID      : <201007081627.24654.johannes.hirte-3kN+8DYepx7zMJDuovMtMLNAH6kLmebB@public.gmane.org>
> > References      : http://marc.info/?l=linux-kernel&m=127859960725931&w=2
> 
> This one is reportedly fixed by commit 83ba7b071f30 ("writeback:
> simplify the write back thread queue")

Closed.

> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=16215
> > Subject         : sysfs: cannot create duplicate filename '/class/net/bnep0'
> > Submitter       : Janusz Krzysztofik <jkrzyszt-NCk8gXQAEuFz6jiHbVrK7g@public.gmane.org>
> > Date            : 2010-06-15 14:55 (48 days old)
> > Handled-By      : Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> Fixed by commit 24b1442d01ae155ea716dfb94ed21605541c317d.

Closed.

Thanks,
Rafael
