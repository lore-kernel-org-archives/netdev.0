From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: 2.6.33-rc3-git3: Reported regressions from 2.6.32
Date: Mon, 11 Jan 2010 08:00:37 -0800
Message-ID: <43e72e891001110800h283b534aj1d60f83266fa215a@mail.gmail.com>
References: <wnS54-l8PVO.A.TlF.oMlSLB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <wnS54-l8PVO.A.TlF.oMlSLB@chimera>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 10, 2010 at 2:27 PM, Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org> wrote:
> This message contains a list of some regressions from 2.6.32, for whi=
ch there
> are no fixes in the mainline I know of. =C2=A0If any of them have bee=
n fixed already,
> please let me know.
>
> If you know of any other unresolved regressions from 2.6.32, please l=
et me know
> either and I'll add them to the list. =C2=A0Also, please let me know =
if any of the
> entries below are invalid.
>
> Each entry from the list will be sent additionally in an automatic re=
ply to
> this message with CCs to the people involved in reporting and handlin=
g the
> issue.
>

Of these only the one below was wireless, which is actually fixed now.
Not bad, rc3 and no wireless regressions yet.

> Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bug.=
cgi?id=3D14874
> Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : Ath5k regression with commit 8b=
f3d79bc401ca417ccf9fc076d3295d1a71dbf5
> Submitter =C2=A0 =C2=A0 =C2=A0 : Joshua Covington <joshuacov@googlema=
il.com>
> Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2009-12-25 00:49 (17 =
days old)
> Handled-By =C2=A0 =C2=A0 =C2=A0: Luis R. Rodriguez <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Patch =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org=
/attachment.cgi?id=3D24335

  Luis
