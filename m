From: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: 2.6.29-rc6: Reported regressions from 2.6.28
Date: Tue, 3 Mar 2009 20:36:10 +0100
Message-ID: <20090303193609.GE27178@atrey.karlin.mff.cuni.cz>
References: <GVhknozYwrL.A.hiC.rozoJB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <GVhknozYwrL.A.hiC.rozoJB@chimera>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

  Hi,

> Unresolved regressions
> ----------------------
> 
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12551
> Subject		: end_request: I/O error, dev cciss/c0d0, sector 87435720
> Submitter	: Ralf Hildebrandt <ralf.hildebrandt-jq1tPX9l7E6ELgA04lAiVw@public.gmane.org>
> Date		: 2009-01-27 06:51 (28 days old)
> 
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12497
> Subject		: new barrier warnings in 2.6.29-rc1
> Submitter	: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
> Date		: 2009-01-12 15:46 (43 days old)
> References	: http://marc.info/?l=linux-kernel&m=123177528217154&w=4
> Handled-By	: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
  I've just noticed that the above two reports are probably the same bug...
Just that we don't duplicate the effort.

									Honza
-- 
Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
SuSE CR Labs
