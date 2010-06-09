From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: 2.6.35-rc2-git2: Reported regressions from 2.6.34
Date: Wed, 09 Jun 2010 08:36:12 +0200
Message-ID: <1276065372.2439.700.camel@edumazet-laptop>
References: <Rlf_Qjov7bG.A.a8F.I8rDMB@chimera>
	 <alpine.LFD.2.00.1006081814240.4506@i5.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Carl Worth <cworth-4HiWtcSh4w0dnm+yROfE0A@public.gmane.org>,
	Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>,
	Venkatesh Pallipadi <venki-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Jens Axboe <jaxboe-5c4llco8/ftWk0Htik3J/w@public.gmane.org>,
	Dave Airlie <airlied-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	David =?ISO-8859-1?Q?H=E4rdeman?= <david-0WFrdVpeebksCylrc8G9yg@public.gmane.org>,
	Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LFD.2.00.1006081814240.4506-GpypE611fyS63QaFMGN2QEqCLAeBNdoH@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le mardi 08 juin 2010 =C3=A0 18:53 -0700, Linus Torvalds a =C3=A9crit :

> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16120
> > Subject	: Oops: 0000 [#1] SMP, unable to handle kernel NULL pointer=
 dereference at (null)
> > Submitter	: Alex Zhavnerchik <alex.vizor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date		: 2010-06-04 09:25 (5 days old)
> > Handled-By	: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>=20
> This one seems to have a patch in bugzilla.

Yep, commit 035320d54758e21227987e3aae0d46e7a04f4ddc in David net-2.6
tree, i'll be included in its next pull request.

http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dcommi=
t;h=3D035320d54758e21227987e3aae0d46e7a04f4ddc

Thanks
