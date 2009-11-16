From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: 2.6.32-rc7-git1: Reported regressions 2.6.30 -> 2.6.31
Date: Tue, 17 Nov 2009 00:35:11 +0100
Message-ID: <200911170035.11575.rjw@sisk.pl>
References: <ipicVA1QUFF.A.zWB.1mdALB@chimera> <4B01E09D.3020608@lwfinger.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4B01E09D.3020608-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 17 November 2009, Larry Finger wrote:
> On 11/16/2009 04:58 PM, Rafael J. Wysocki wrote:
> > This message contains a list of some regressions introduced between 2.6.30 and
> > 2.6.31, for which there are no fixes in the mainline I know of.  If any of them
> > have been fixed already, please let me know.
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14181
> > Subject		: b43 causes panic at ifconfig down / shutdown
> > Submitter	: Jeremy Huddleston <jeremyhu-CC+yJ3UmIYqDUpFQwHEjaQ@public.gmane.org>
> > Date		: 2009-09-15 18:34 (63 days old)
> 
> This one is fixed by commit d50bae33d1358b909ade05ae121d83d3a60ab63f in
> mainline. The patch was also sent to stable.

Thanks, closed.

Rafael
