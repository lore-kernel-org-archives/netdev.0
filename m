From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.35-rc2-git2: Reported regressions from 2.6.34
Date: Wed, 9 Jun 2010 07:24:12 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.1006090719440.4506@i5.linux-foundation.org>
References: <Rlf_Qjov7bG.A.a8F.I8rDMB@chimera> <alpine.LFD.2.00.1006081814240.4506@i5.linux-foundation.org> <201006091106.11232.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Carl Worth <cworth@cworth.org>, Eric Anholt <eric@anholt.net>,
	Venkatesh Pallipadi <venki@google.com>,
	Jens Axboe <jaxboe@fusionio.com>,
	Dave Airlie <airlied@gmail.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	Ingo Molnar <mingo@elte.hu>,
	=?ISO-8859-15?Q?David__H=E4rdeman?= <david@hardeman.nu>,
	Mauro Carvalho Chehab <mchehab@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
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
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <201006091106.11232.rjw@sisk.pl>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 9 Jun 2010, Rafael J. Wysocki wrote:
> > 
> > That has a "reverting the commit fixes it", and a confirmation from Nick 
> > Bowler.
> > 
> > Eric, Carl: should I just revert that commit? Or do you have a fix?
> 
> This one is reported to have been fixed already.  Closed now.

Heh. That "fixed already" is actually the revert. Carl acked it.

> This should be fixed by commit f8ed8b4c5d30b5214f185997131b06e35f6f7113, so
> closing now.

Good, that was in yesterday's drm pull.

		Linus
