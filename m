From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: 2.6.30-rc7: Reported regressions from 2.6.29
Date: Mon, 25 May 2009 00:20:42 +0200
Message-ID: <200905250020.43820.rjw@sisk.pl>
References: <ZPPBiNHr1LC.A.9ZH.K9bGKB@chimera> <4A19C51D.7020609@pardus.org.tr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
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
To: Ozan =?utf-8?q?=C3=87a=C4=9Flayan?= <ozan-caicS1wCkhO6A22drWdTBw@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4A19C51D.7020609-caicS1wCkhO6A22drWdTBw@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 25 May 2009, Ozan =C3=87a=C4=9Flayan wrote:
> Rafael J. Wysocki wrote:
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13326
> > Subject		: [PATCH]Null pointer dereference in rtc-cmos driver
> > Submitter	: Ozan =C3=87a=C4=9Flayan <ozan-caicS1wCkhO6A22drWdTBw@public.gmane.org>
> > Date		: 2009-05-14 16:16 (11 days old)
> > References	: http://marc.info/?l=3Dlinux-kernel&m=3D124231783704696=
&w=3D4
> >  =20
>=20
> Just to notice that the patch for this is at:
>=20
> http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patch=
es/driver-core.current/driver-core-do-not-oops-when-driver_unregister-i=
s-called-for-unregistered-drivers.patch
>=20
> Can at least be marked as "has a patch".

Thanks, I added the patch to the bug entry and changed its status.

Best,
Rafael
