From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: 2.6.30-rc2-git2: Reported regressions from 2.6.29
Date: Sat, 18 Apr 2009 14:29:57 +0200
Message-ID: <200904181429.58406.rjw@sisk.pl>
References: <EJaiQ4Wfaz.A.3YG.4v85JB@chimera> <200904172336.12414.rjw@sisk.pl> <200904180156.24366.laurent.pinchart@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	video4linux-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
To: Laurent Pinchart <laurent.pinchart-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200904180156.24366.laurent.pinchart-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 18 April 2009, Laurent Pinchart wrote:
> Hi,
> 
> On Friday 17 April 2009 23:36:11 Rafael J. Wysocki wrote:
> > On Friday 17 April 2009, Ming Lei wrote:
> > > 2009/4/17 Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>:
> > > > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=13125
> > > > Subject         : active uvcvideo breaks over suspend
> > > > Submitter       : Alan Jenkins <alan-jenkins-cCz0Lq7MMjm9FHfhHBbuYA@public.gmane.org>
> > > > Date            : 2009-04-15 10:12 (2 days old)
> > > > References      :
> > > > http://marc.info/?l=linux-kernel&m=123979009508840&w=4
> > >
> > > It is a bug in resume path of uvcvideo driver, and I have sent a patch
> > > to laurent.pinchart-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org,
> > > mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org  and video4linux-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org to fix it, but
> > > still no echo from them.
> > >
> > > The patch title is V4L/DVB:usbvideo:fix uvc resume failed.
> > >
> > > Rafael J.
> > >         If you would like to apply it ,I can resend to you.  Thanks!
> >
> > Please resend.
> 
> I'm reviewing the patch and I'll push it through my tree during the weekend. 

Great, thanks a lot!

> Sorry for the delay, I'm currently traveling.

No problem at all. :-)

Thanks,
Rafael
