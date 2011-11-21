From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 3.2-rc2+: Reported regressions from 3.0 and 3.1
Date: Mon, 21 Nov 2011 22:49:30 +0100
Message-ID: <201111212249.31196.rjw@sisk.pl>
References: <lx6sezwGldO.A.IhF.UBpWOB@chimera>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <lx6sezwGldO.A.IhF.UBpWOB@chimera>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions from 3.0 and 3.1
for which there are no fixes in the mainline known to the tracking team=
=2E
If any of them have been fixed already, please let us know.

If you know of any other unresolved regressions from 3.0 and 3.1, pleas=
e let us
know either and we'll add them to the list.  Also, please let us know i=
f any of
the entries below are invalid.

The entries below are simplified and the statistics are not present due=
 to the
continuing Bugzilla outage.

Subject    : iwlagn is getting very shaky
Submitter  : Norbert Preining <preining-DX+603jRYB8@public.gmane.org>
Date       : 2011-10-19 6:01
Message-ID : 20111019060108.GA11588-DqSSrKF0TaySnEC3TeqHn5dqbFPxfnh/@public.gmane.org
References : http://marc.info/?l=3Dlinux-kernel&m=3D131914553920614&w=3D=
2

Subject    : Regression: "irqpoll" hasn't been working for me since Mar=
ch 16 IRQ
Submitter  : Edward Donovan <edward.donovan-mb/Bq7DTvoSsTnJN9+BGXg@public.gmane.org>
Date       : 2011-10-19 22:09
Message-ID : CADdbW+HXdCPfJu2RTF6zz+ujCmiu_dmZwL2iScuF53p=3DAaZ1Uw@mail=
=2Egmail.com
References : http://marc.info/?l=3Dlinux-kernel&m=3D131914554220679&w=3D=
2

Subject    : Regression in 3.1 causes Xen to use wrong idle routine
Submitter  : Stefan Bader <stefan.bader-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Date       : 2011-10-26 10:24
Message-ID : 4EA7DFD1.9060608-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
References : http://marc.info/?l=3Dlinux-acpi&m=3D131962467924564&w=3D2

Subject    : 3.1+ iwlwifi lockup
Submitter  : Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date       : 2011-10-31 14:34
Message-ID : 20111031143408.GA17152-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
References : http://marc.info/?l=3Dlinux-kernel&m=3D132007169420160&w=3D=
2

Subject    : hugetlb oops on 3.1.0-rc8-devel
Submitter  : Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Date       : 2011-11-01 22:20
Message-ID : CALCETrW1mpVCz2tO5roaz1r6vnno+srHR-dHA6_pkRi2qiCfdw@mail.g=
mail.com
References : http://marc.info/?l=3Dlinux-kernel&m=3D132018604426692&w=3D=
2

Subject    : Simultaneous cat and external keyboard input causing kerne=
l panic
Submitter  : Timo Jyrinki <timo.jyrinki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date       : 2011-11-03 12:14
Message-ID : CAJtFfxmovJHspHHKbvBVc4pw+u5mjGmUejCXEzdV+GqE=3DjVSOQ@mail=
=2Egmail.com
References : http://marc.info/?l=3Dlinux-kernel&m=3D132032253903074&w=3D=
2

Subject    : Linus GIT - INFO: possible circular locking dependency det=
ected
Submitter  : Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date       : 2011-11-03 15:57
Message-ID : CAHFgRy8S0xLfhZxTUOEH5A0PL_Fb79-0-gmbQ=3D9h2D-xMqt1hA@mail=
=2Egmail.com
References : http://marc.info/?l=3Dlinux-kernel&m=3D132033587908426&w=3D=
2

Subject    : lockdep warning after aa6afca5bcab: "proc: fix races again=
st execve() of /proc/PID/fd**"
Submitter  : Ari Savolainen <ari.m.savolainen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date       : 2011-11-08 3:47
Message-ID : CAEbykaXYZEFhTgWMm2AfaWQ2SaXYuO_ypTnw+6AVWScOYSCuuw@mail.g=
mail.com
References : http://marc.info/?l=3Dlinux-kernel&m=3D132072413125099&w=3D=
2

Subject    : DMA-API check_sync errors with 3.2
Submitter  : Josh Boyer <jwboyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date       : 2011-11-08 17:31
Message-ID : 20111108173153.GE14216-8k7Gwy46GHkf7BdofF/totBPR1lH4CV8@public.gmane.org
References : http://marc.info/?l=3Dlinux-kernel&m=3D132077357608797&w=3D=
2

Subject    : [3.1-rc8 REGRESSION] sky2 hangs machine on turning off or =
suspending
Submitter  : Rafa=C5=82 Mi=C5=82ecki <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date       : 2011-11-09 11:46
Message-ID : CACna6ryTdLcWVYgHu=3D_mRFga1sFivpE_DyZOY-HMmKggkWAJAw@mail=
=2Egmail.com
References : http://marc.info/?l=3Dlinux-netdev&m=3D132083922228088&w=3D=
4

Subject    : 3.2-rc1 doesn't boot on dual socket opteron without swap
Submitter  : Niklas Schnelle <niklas-74wnUeZ+fLazQB+pC5nmwQ@public.gmane.org>
Date       : 2011-11-10 20:09
Message-ID : 1320955769.1718.8.camel@jupiter
References : http://marc.info/?l=3Dlinux-kernel&m=3D132095583501767&w=3D=
2

Subject    : Sparc-32 doesn't work in 3.1.
Submitter  : Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Date       : 2011-11-12 11:22
Message-ID : 4EBEAB5A.5020809-VoJi6FS/r0vR7s880joybQ@public.gmane.org
References : http://www.spinics.net/lists/kernel/msg1260383.html

Subject    : khugepaged blocks suspend2ram (3.2.0-rc1-00252-g8f042aa)
Submitter  : Sergei Trofimovich <slyich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date       : 2011-11-12 10:48
Message-ID : 20111112104859.7744b282-rUBWEpAk+NE@public.gmane.org
References : https://lkml.org/lkml/2011/11/12/11

Subject    : WARNING: at fs/sysfs/sysfs.h:195 (during boot)
Submitter  : Markus Trippelsdorf <markus-xp2qqqlHh3xzoYq+O6RWwA@public.gmane.org>
Date       : 2011-11-13 19:24
Message-ID : 20111113192417.GA1659-tLCgZGx+iJ+kxVt8IV0GqQ@public.gmane.org
References : http://marc.info/?l=3Dlinux-kernel&m=3D132121231921932&w=3D=
2

Subject    : PROBLEM: Radeon display connector : No monitor connected o=
r invalid EDID
Submitter  : Treeve Jelbert <treeve-rJAIWvhRp0CZIoH1IeqzKA@public.gmane.org>
Date       : 2011-11-13 17:27
Message-ID : 2407026.akcTO2Ggic@gemini-64
References : http://marc.info/?l=3Dlinux-kernel&m=3D132120530920139&w=3D=
2

Subject    : [3.1 REGRESSION] Commit 5cec93c216db77c45f7ce970d46283bcb1=
933884 breaks the Chromium seccomp sandbox
Submitter  : Nix <nix-dKoSMcxRz+Te9xe1eoZjHA@public.gmane.org>
Date       : 2011-11-14 0:40
Message-ID : 8762inleno.fsf-AdTWujXS48Mg67Zj9sPl2A@public.gmane.org
References : http://marc.info/?l=3Dlinux-kernel&m=3D132123396226377&w=3D=
2

Subject    : max PWM is zero
Submitter  : Marcos Paulo de Souza <marcos.mage-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date       : 2011-11-15 15:14
Message-ID : alpine.LNX.2.00.1111151301410.2693-4/PLUo9XfK9uYUHNOcvv8+TW4wlIGRCZ@public.gmane.org
References : http://marc.info/?l=3Dlinux-kernel&m=3D132137019330548&w=3D=
2

Subject    : Oops on suspend with libertas SDIO (Linux 3.2-rc2)
Submitter  : Sven Neumann <s.neumann-5g8ninUHluJWk0Htik3J/w@public.gmane.org>
Date       : 2011-11-17 15:36
Message-ID : 1321544210.31090.6.camel@sven
References : http://marc.info/?l=3Dlinux-kernel&m=3D132154527715807&w=3D=
2

Subject    : Impossible high cpu-time values for migration threads
Submitter  : Markus Trippelsdorf <markus-xp2qqqlHh3xzoYq+O6RWwA@public.gmane.org>
Date       : 2011-11-17 22:17
Message-ID : 20111117221731.GA9229-tLCgZGx+iJ+kxVt8IV0GqQ@public.gmane.org
References : http://marc.info/?l=3Dlinux-kernel&m=3D132156832124314&w=3D=
2

Subject    : WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Submitter  : Markus Trippelsdorf <markus-xp2qqqlHh3xzoYq+O6RWwA@public.gmane.org>
Date       : 2011-11-18 7:25
Message-ID : 20111118072519.GA1615-tLCgZGx+iJ+kxVt8IV0GqQ@public.gmane.org
References : http://marc.info/?l=3Dlinux-kernel&m=3D132160119031794&w=3D=
2

Subject    : [REGRESSION] resume takes 10s longer due to e1b6eb3 (Bluet=
ooth: Increase HCI reset timeout ...)
Submitter  : Tom=C3=A1=C5=A1 Janou=C5=A1ek <tomi-YoqI/XImC7s@public.gmane.org>
Date       : 2011-11-18 18:40
Message-ID : 20111118184017.GA5052-YoqI/XImC7s@public.gmane.org
References : http://marc.info/?l=3Dlinux-kernel&m=3D132164169511416&w=3D=
2

Subject    : [REGRESSION] sudden cpu hogging in kernel 3.2 rc-series
Submitter  : "Nicolas Kalkhof" <nkalkhof-S0/GAf8tV78@public.gmane.org>
Date       : 2011-11-18 20:33
Message-ID : 506786689.810044.1321648395265.JavaMail.fmail@mwmweb010
References : http://marc.info/?l=3Dlinux-kernel&m=3D132164909313594&w=3D=
2

Thanks!
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
