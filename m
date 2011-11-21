From: Alex Deucher <alexdeucher-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: 3.2-rc2+: Reported regressions from 3.0 and 3.1
Date: Mon, 21 Nov 2011 17:29:17 -0500
Message-ID: <CADnq5_PJ5rAvmjwSfh23A7QsUZEvGQHKYOE8CVtCYqeLM2T7-Q@mail.gmail.com>
References: <lx6sezwGldO.A.IhF.UBpWOB@chimera>
	<201111212249.31196.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>,
	Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201111212249.31196.rjw-KKrjLPT3xs0@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 21, 2011 at 4:49 PM, Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org> wrote:
> This message contains a list of some regressions from 3.0 and 3.1
> for which there are no fixes in the mainline known to the tracking te=
am.
> If any of them have been fixed already, please let us know.
>
> If you know of any other unresolved regressions from 3.0 and 3.1, ple=
ase let us
> know either and we'll add them to the list. =A0Also, please let us kn=
ow if any of
> the entries below are invalid.
>
> The entries below are simplified and the statistics are not present d=
ue to the
> continuing Bugzilla outage.
>
> Subject =A0 =A0: iwlagn is getting very shaky
> Submitter =A0: Norbert Preining <preining-DX+603jRYB8@public.gmane.org>
> Date =A0 =A0 =A0 : 2011-10-19 6:01
> Message-ID : 20111019060108.GA11588-DqSSrKF0TaySnEC3TeqHn5dqbFPxfnh/@public.gmane.org
> References : http://marc.info/?l=3Dlinux-kernel&m=3D131914553920614&w=
=3D2
>
> Subject =A0 =A0: Regression: "irqpoll" hasn't been working for me sin=
ce March 16 IRQ
> Submitter =A0: Edward Donovan <edward.donovan-mb/Bq7DTvoSsTnJN9+BGXg@public.gmane.org>
> Date =A0 =A0 =A0 : 2011-10-19 22:09
> Message-ID : CADdbW+HXdCPfJu2RTF6zz+ujCmiu_dmZwL2iScuF53p=3DAaZ1Uw@ma=
il.gmail.com
> References : http://marc.info/?l=3Dlinux-kernel&m=3D131914554220679&w=
=3D2
>
> Subject =A0 =A0: Regression in 3.1 causes Xen to use wrong idle routi=
ne
> Submitter =A0: Stefan Bader <stefan.bader-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Date =A0 =A0 =A0 : 2011-10-26 10:24
> Message-ID : 4EA7DFD1.9060608-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
> References : http://marc.info/?l=3Dlinux-acpi&m=3D131962467924564&w=3D=
2
>
> Subject =A0 =A0: 3.1+ iwlwifi lockup
> Submitter =A0: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Date =A0 =A0 =A0 : 2011-10-31 14:34
> Message-ID : 20111031143408.GA17152-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132007169420160&w=
=3D2
>
> Subject =A0 =A0: hugetlb oops on 3.1.0-rc8-devel
> Submitter =A0: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
> Date =A0 =A0 =A0 : 2011-11-01 22:20
> Message-ID : CALCETrW1mpVCz2tO5roaz1r6vnno+srHR-dHA6_pkRi2qiCfdw@mail=
=2Egmail.com
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132018604426692&w=
=3D2
>
> Subject =A0 =A0: Simultaneous cat and external keyboard input causing=
 kernel panic
> Submitter =A0: Timo Jyrinki <timo.jyrinki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date =A0 =A0 =A0 : 2011-11-03 12:14
> Message-ID : CAJtFfxmovJHspHHKbvBVc4pw+u5mjGmUejCXEzdV+GqE=3DjVSOQ@ma=
il.gmail.com
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132032253903074&w=
=3D2
>
> Subject =A0 =A0: Linus GIT - INFO: possible circular locking dependen=
cy detected
> Submitter =A0: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date =A0 =A0 =A0 : 2011-11-03 15:57
> Message-ID : CAHFgRy8S0xLfhZxTUOEH5A0PL_Fb79-0-gmbQ=3D9h2D-xMqt1hA@ma=
il.gmail.com
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132033587908426&w=
=3D2
>
> Subject =A0 =A0: lockdep warning after aa6afca5bcab: "proc: fix races=
 against execve() of /proc/PID/fd**"
> Submitter =A0: Ari Savolainen <ari.m.savolainen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date =A0 =A0 =A0 : 2011-11-08 3:47
> Message-ID : CAEbykaXYZEFhTgWMm2AfaWQ2SaXYuO_ypTnw+6AVWScOYSCuuw@mail=
=2Egmail.com
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132072413125099&w=
=3D2
>
> Subject =A0 =A0: DMA-API check_sync errors with 3.2
> Submitter =A0: Josh Boyer <jwboyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Date =A0 =A0 =A0 : 2011-11-08 17:31
> Message-ID : 20111108173153.GE14216-8k7Gwy46GHkf7BdofF/totBPR1lH4CV8@public.gmane.org
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132077357608797&w=
=3D2
>
> Subject =A0 =A0: [3.1-rc8 REGRESSION] sky2 hangs machine on turning o=
ff or suspending
> Submitter =A0: Rafa=B3 Mi=B3ecki <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date =A0 =A0 =A0 : 2011-11-09 11:46
> Message-ID : CACna6ryTdLcWVYgHu=3D_mRFga1sFivpE_DyZOY-HMmKggkWAJAw@ma=
il.gmail.com
> References : http://marc.info/?l=3Dlinux-netdev&m=3D132083922228088&w=
=3D4
>
> Subject =A0 =A0: 3.2-rc1 doesn't boot on dual socket opteron without =
swap
> Submitter =A0: Niklas Schnelle <niklas-74wnUeZ+fLazQB+pC5nmwQ@public.gmane.org>
> Date =A0 =A0 =A0 : 2011-11-10 20:09
> Message-ID : 1320955769.1718.8.camel@jupiter
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132095583501767&w=
=3D2
>
> Subject =A0 =A0: Sparc-32 doesn't work in 3.1.
> Submitter =A0: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
> Date =A0 =A0 =A0 : 2011-11-12 11:22
> Message-ID : 4EBEAB5A.5020809-VoJi6FS/r0vR7s880joybQ@public.gmane.org
> References : http://www.spinics.net/lists/kernel/msg1260383.html
>
> Subject =A0 =A0: khugepaged blocks suspend2ram (3.2.0-rc1-00252-g8f04=
2aa)
> Submitter =A0: Sergei Trofimovich <slyich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date =A0 =A0 =A0 : 2011-11-12 10:48
> Message-ID : 20111112104859.7744b282-rUBWEpAk+NE@public.gmane.org
> References : https://lkml.org/lkml/2011/11/12/11
>
> Subject =A0 =A0: WARNING: at fs/sysfs/sysfs.h:195 (during boot)
> Submitter =A0: Markus Trippelsdorf <markus-xp2qqqlHh3xzoYq+O6RWwA@public.gmane.org>
> Date =A0 =A0 =A0 : 2011-11-13 19:24
> Message-ID : 20111113192417.GA1659-tLCgZGx+iJ+kxVt8IV0GqQ@public.gmane.org
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132121231921932&w=
=3D2
>
> Subject =A0 =A0: PROBLEM: Radeon display connector : No monitor conne=
cted or invalid EDID
> Submitter =A0: Treeve Jelbert <treeve-rJAIWvhRp0CZIoH1IeqzKA@public.gmane.org>
> Date =A0 =A0 =A0 : 2011-11-13 17:27
> Message-ID : 2407026.akcTO2Ggic@gemini-64
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132120530920139&w=
=3D2

Treeve replied to me directly saying the it was a problem with his
config file and everything is working fine now.

Alex

>
> Subject =A0 =A0: [3.1 REGRESSION] Commit 5cec93c216db77c45f7ce970d462=
83bcb1933884 breaks the Chromium seccomp sandbox
> Submitter =A0: Nix <nix-dKoSMcxRz+Te9xe1eoZjHA@public.gmane.org>
> Date =A0 =A0 =A0 : 2011-11-14 0:40
> Message-ID : 8762inleno.fsf-AdTWujXS48Mg67Zj9sPl2A@public.gmane.org
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132123396226377&w=
=3D2
>
> Subject =A0 =A0: max PWM is zero
> Submitter =A0: Marcos Paulo de Souza <marcos.mage-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date =A0 =A0 =A0 : 2011-11-15 15:14
> Message-ID : alpine.LNX.2.00.1111151301410.2693-4/PLUo9XfK9uYUHNOcvv8+TW4wlIGRCZ@public.gmane.org
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132137019330548&w=
=3D2
>
> Subject =A0 =A0: Oops on suspend with libertas SDIO (Linux 3.2-rc2)
> Submitter =A0: Sven Neumann <s.neumann-5g8ninUHluJWk0Htik3J/w@public.gmane.org>
> Date =A0 =A0 =A0 : 2011-11-17 15:36
> Message-ID : 1321544210.31090.6.camel@sven
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132154527715807&w=
=3D2
>
> Subject =A0 =A0: Impossible high cpu-time values for migration thread=
s
> Submitter =A0: Markus Trippelsdorf <markus-xp2qqqlHh3xzoYq+O6RWwA@public.gmane.org>
> Date =A0 =A0 =A0 : 2011-11-17 22:17
> Message-ID : 20111117221731.GA9229-tLCgZGx+iJ+kxVt8IV0GqQ@public.gmane.org
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132156832124314&w=
=3D2
>
> Subject =A0 =A0: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:=
3413
> Submitter =A0: Markus Trippelsdorf <markus-xp2qqqlHh3xzoYq+O6RWwA@public.gmane.org>
> Date =A0 =A0 =A0 : 2011-11-18 7:25
> Message-ID : 20111118072519.GA1615-tLCgZGx+iJ+kxVt8IV0GqQ@public.gmane.org
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132160119031794&w=
=3D2
>
> Subject =A0 =A0: [REGRESSION] resume takes 10s longer due to e1b6eb3 =
(Bluetooth: Increase HCI reset timeout ...)
> Submitter =A0: Tom=E1=B9 Janou=B9ek <tomi-YoqI/XImC7s@public.gmane.org>
> Date =A0 =A0 =A0 : 2011-11-18 18:40
> Message-ID : 20111118184017.GA5052-YoqI/XImC7s@public.gmane.org
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132164169511416&w=
=3D2
>
> Subject =A0 =A0: [REGRESSION] sudden cpu hogging in kernel 3.2 rc-ser=
ies
> Submitter =A0: "Nicolas Kalkhof" <nkalkhof-S0/GAf8tV78@public.gmane.org>
> Date =A0 =A0 =A0 : 2011-11-18 20:33
> Message-ID : 506786689.810044.1321648395265.JavaMail.fmail@mwmweb010
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132164909313594&w=
=3D2
>
> Thanks!
> _______________________________________________
> dri-devel mailing list
> dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org
> http://lists.freedesktop.org/mailman/listinfo/dri-devel
>
