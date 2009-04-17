From: Laurent Pinchart <laurent.pinchart@skynet.be>
Subject: Re: 2.6.30-rc2-git2: Reported regressions from 2.6.29
Date: Sat, 18 Apr 2009 01:56:23 +0200
Message-ID: <200904180156.24366.laurent.pinchart@skynet.be>
References: <EJaiQ4Wfaz.A.3YG.4v85JB@chimera> <d82e647a0904161837w6b6fb652la0da05f9061e95dc@mail.gmail.com> <200904172336.12414.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <tom.leiming@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	video4linux-list@redhat.com, mchehab@infradead.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <200904172336.12414.rjw@sisk.pl>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Friday 17 April 2009 23:36:11 Rafael J. Wysocki wrote:
> On Friday 17 April 2009, Ming Lei wrote:
> > 2009/4/17 Rafael J. Wysocki <rjw@sisk.pl>:
> > > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=13125
> > > Subject         : active uvcvideo breaks over suspend
> > > Submitter       : Alan Jenkins <alan-jenkins@tuffmail.co.uk>
> > > Date            : 2009-04-15 10:12 (2 days old)
> > > References      :
> > > http://marc.info/?l=linux-kernel&m=123979009508840&w=4
> >
> > It is a bug in resume path of uvcvideo driver, and I have sent a patch
> > to laurent.pinchart@skynet.be,
> > mchehab@infradead.org  and video4linux-list@redhat.com to fix it, but
> > still no echo from them.
> >
> > The patch title is V4L/DVB:usbvideo:fix uvc resume failed.
> >
> > Rafael J.
> >         If you would like to apply it ,I can resend to you.  Thanks!
>
> Please resend.

I'm reviewing the patch and I'll push it through my tree during the weekend. 
Sorry for the delay, I'm currently traveling.

Best regards,

Laurent Pinchart

