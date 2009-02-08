From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: 2.6.29-rc4: Reported regressions from 2.6.28
Date: Sun, 8 Feb 2009 23:04:52 +0100
Message-ID: <200902082304.53585.rjw@sisk.pl>
References: <AIghyjFgMFP.A.uZD._10jJB@chimera> <alpine.LFD.2.00.0902081354150.3048@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LFD.2.00.0902081354150.3048-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 08 February 2009, Linus Torvalds wrote:
> 
> On Sun, 8 Feb 2009, Rafael J. Wysocki wrote:
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12669
> > Subject		: 2.6.28.4 regression: mmap fails if mlockall used
> > Submitter	: Sami Farin <safari-kernel-nmB1AuG+Lnw9NyIDpsMsJw@public.gmane.org>
> > Date		: 2009-02-08 10:52 (1 days old)
> > References	: http://marc.info/?l=linux-kernel&m=123409037423068&w=4
> 
> Oh, Hugh just sent a patch, and it's now commit 
> d5b562330ec766292a3ac54ae5e0673610bd5b3d. Sadly this just missed -rc4 by 
> something like 20 minutes..

Yes, I saw the Hugh's message right after sending the report.

Bug closed.

Thanks,
Rafael
