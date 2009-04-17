From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.30-rc2-git2: Reported regressions from 2.6.29
Date: Fri, 17 Apr 2009 23:36:11 +0200
Message-ID: <200904172336.12414.rjw@sisk.pl>
References: <EJaiQ4Wfaz.A.3YG.4v85JB@chimera> <d82e647a0904161837w6b6fb652la0da05f9061e95dc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
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
	video4linux-list@redhat.com, laurent.pinchart@skynet.be,
	mchehab@infradead.org
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <d82e647a0904161837w6b6fb652la0da05f9061e95dc@mail.gmail.com>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 17 April 2009, Ming Lei wrote:
> 2009/4/17 Rafael J. Wysocki <rjw@sisk.pl>:
> >
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=13125
> > Subject         : active uvcvideo breaks over suspend
> > Submitter       : Alan Jenkins <alan-jenkins@tuffmail.co.uk>
> > Date            : 2009-04-15 10:12 (2 days old)
> > References      : http://marc.info/?l=linux-kernel&m=123979009508840&w=4
> >
> 
> It is a bug in resume path of uvcvideo driver, and I have sent a patch
> to laurent.pinchart@skynet.be,
> mchehab@infradead.org  and video4linux-list@redhat.com to fix it, but
> still no echo from them.
> 
> The patch title is V4L/DVB:usbvideo:fix uvc resume failed.
> 
> Rafael J.
>         If you would like to apply it ,I can resend to you.  Thanks!

Please resend.

Rafael
