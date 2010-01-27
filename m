From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Bug #15042] socket(PF_INET6 hangs when ipv6 not yet initialized
Date: Wed, 27 Jan 2010 17:10:44 +0800
Message-ID: <2375c9f91001270110t2a8d08b8n4578df310a6129@mail.gmail.com>
References: <pYFNu11z2aM.A.pJH.CZMXLB@chimera>
	 <q60Z28d_9yH.A.oqH.NZMXLB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Marc Haber <mh+linux-kernel-ciUMMiFYEj8OIzVOb1FTxg@public.gmane.org>,
	Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <q60Z28d_9yH.A.oqH.NZMXLB@chimera>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 25, 2010 at 6:23 AM, Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org> wrote:
> This message has been generated automatically as a part of a report
> of regressions introduced between 2.6.31 and 2.6.32.
>
> The following bug entry is on the current list of known regressions
> introduced between 2.6.31 and 2.6.32. =C2=A0Please verify if it still=
 should
> be listed and let me know (either way).
>
>
> Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bug.=
cgi?id=3D15042
> Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : socket(PF_INET6 hangs when ipv6=
 not yet initialized
> Submitter =C2=A0 =C2=A0 =C2=A0 : Marc Haber <mh+linux-kernel@zugschlu=
s.de>
> Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2010-01-10 14:28 (15 =
days old)
> References =C2=A0 =C2=A0 =C2=A0: http://marc.info/?l=3Dlinux-kernel&m=
=3D126313553029280&w=3D4
>

(Adding net-dev into Cc)

Hi, Marc,

Sorry, I don't really understand your description of the problem, your =
mean
your ssh hangs on socket PF_INET6 for 30 seconds?

Have you enabled CONFIG_DETECT_SOFTLOCKUP for your kernel?
If not, please do it.

Thanks.
