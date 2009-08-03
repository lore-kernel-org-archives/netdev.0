From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: 2.6.31-rc5: Reported regressions 2.6.29 -> 2.6.30
Date: Mon, 3 Aug 2009 08:16:39 -0700
Message-ID: <43e72e890908030816n187cda20keda2c9ba1b15a89c@mail.gmail.com>
References: <upey9ZSfnaF.A.-oE.rpgdKB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
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
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, rootkit85-whZMOeQn8C0@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <upey9ZSfnaF.A.-oE.rpgdKB@chimera>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Here are the wireless ones:

On Sun, Aug 2, 2009 at 12:06 PM, Rafael J. Wysocki<rjw-KKrjLPT3xs0@public.gmane.org> wrote:

> Unresolved regressions
> ----------------------
>
> Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bug.=
cgi?id=3D13898
> Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : Intel 3945ABG - problems on 2.6=
=2E30.X
> Submitter =C2=A0 =C2=A0 =C2=A0 : dienet <dienet-IjDXvh/HVVUAvxtiuMwx3w@public.gmane.org>
> Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2009-07-31 15:17 (3 d=
ays old)
> References =C2=A0 =C2=A0 =C2=A0: http://marc.info/?l=3Dlinux-kernel&m=
=3D124905346729959&w=3D4


> Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bug.=
cgi?id=3D13638
> Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : rt2870 driver is broken for (so=
me) cards
> Submitter =C2=A0 =C2=A0 =C2=A0 : jakob gruber <jakob.gruber@kabelnet.=
at>
> Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2009-06-27 17:33 (37 =
days old)



> Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bug.=
cgi?id=3D13581
> Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : ath9k doesn't work with newer k=
ernels
> Submitter =C2=A0 =C2=A0 =C2=A0 : Matteo <rootkit85-whZMOeQn8C0@public.gmane.org>
> Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2009-06-19 12:04 (45 =
days old)

Issue looks more like a the user has rfkill enabled rather than a
driver issue. Waiting on user feedback since 2009-07-27.

> Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bug.=
cgi?id=3D13362
> Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : rt2x00: slow wifi with correct =
basic rate bitmap
> Submitter =C2=A0 =C2=A0 =C2=A0 : Alejandro Riveira <ariveira-Re5JQEeQqe8@public.gmane.org=
m>
> Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2009-05-22 13:32 (73 =
days old)



> Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bug.=
cgi?id=3D13337
> Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : [post 2.6.29 regression] hang d=
uring suspend of b44/b43 modules
> Submitter =C2=A0 =C2=A0 =C2=A0 : Tomas Janousek <tomi-YoqI/XImC7s@public.gmane.org>
> Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2009-05-18 10:59 (77 =
days old)
> Handled-By =C2=A0 =C2=A0 =C2=A0: Johannes Berg <johannes@sipsolutions=
=2Enet>
> Patch =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : http://patchwork.kernel.or=
g/patch/37837/


> Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bug.=
cgi?id=3D13319
> Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : Page allocation failures with b=
43 and p54usb
> Submitter =C2=A0 =C2=A0 =C2=A0 : Larry Finger <Larry.Finger@lwfinger.=
net>
> Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2009-04-29 21:01 (96 =
days old)
> References =C2=A0 =C2=A0 =C2=A0: http://marc.info/?l=3Dlinux-kernel&m=
=3D124103897101088&w=3D4
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0http://=
lkml.org/lkml/2009/6/7/136
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0http://=
lkml.org/lkml/2009/7/26/213
> Handled-By =C2=A0 =C2=A0 =C2=A0: Johannes Berg <johannes@sipsolutions=
=2Enet>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0David R=
ientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Patch =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : http://patchwork.kernel.or=
g/patch/37655/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
