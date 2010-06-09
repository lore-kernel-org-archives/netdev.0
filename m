From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: 2.6.35-rc2-git2: Reported regressions from 2.6.34
Date: Wed, 9 Jun 2010 11:00:32 +0200
Message-ID: <201006091100.32494.rjw@sisk.pl>
References: <Rlf_Qjov7bG.A.a8F.I8rDMB@chimera> <alpine.LFD.2.00.1006081814240.4506@i5.linux-foundation.org> <4C0EFBC1.5090401@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Carl Worth <cworth-4HiWtcSh4w0dnm+yROfE0A@public.gmane.org>, Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>,
	Venkatesh Pallipadi <venki-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Jens Axboe <jaxboe-5c4llco8/ftWk0Htik3J/w@public.gmane.org>,
	Dave Airlie <airlied-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	David =?iso-8859-15?q?H=E4rdeman?= <david-0WFrdVpeebksCylrc8G9yg@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
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
To: Mauro Carvalho Chehab <mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4C0EFBC1.5090401-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 09 June 2010, Mauro Carvalho Chehab wrote:
> Em 08-06-2010 22:53, Linus Torvalds escreveu:
>=20
> >=20
> >> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16037
> >> Subject	: NULL Pointer dereference in __ir_input_register/budget_c=
i_attach
> >> Submitter	: Sean Finney <seanius-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>
> >> Date		: 2010-05-23 19:52 (17 days old)
> >=20
> > Perhaps related to commit 13c24497086418010bf4f76378bcae241d7f59cd?
> >=20
> > David H=E4rdeman, Mauro Carvalho Chehab added to cc.
>=20
> This patch probably solves the issue:
>=20
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff;h=3D84b14f181a36eea6591779156ef356f8d198bbfd
>=20
> The patch were already applied upstream. I've already asked the repor=
ter to test it, via BZ.

Confirmed fixed, so closing.

Thanks,
Rafael
