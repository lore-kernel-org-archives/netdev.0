From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.38-rc7-git4: Reported regressions from 2.6.37
Date: Sun,  6 Mar 2011 13:08:06 +0100 (CET)
Message-ID: <t0W8Ea1iKeB.A.6xD.Lp3cNB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
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
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions from 2.6.37,
for which there are no fixes in the mainline known to the tracking team=
=2E
If any of them have been fixed already, please let us know.

If you know of any other unresolved regressions from 2.6.37, please let=
 us
know either and we'll add them to the list.  Also, please let us know
if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic repl=
y
to this message with CCs to the people involved in reporting and handli=
ng
the issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2011-03-06       70       27          26
  2011-02-21       51       18          17
  2011-02-12       39       20          18
  2011-02-03       19       11           7


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D30472
Subject		: 2.6.38-post-rc7 with radeon kms: reproducably locks up hard =
when using desktop cube of kwin
Submitter	: Martin Steigerwald <Martin-3kZCPVa5dk2azgQtNeiOUg@public.gmane.org>
Date		: 2011-03-05 15:10:24 (2 days old)
Message-ID	: <201103051510.35057.Martin-3kZCPVa5dk2azgQtNeiOUg@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129933425306804&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D30462
Subject		: High cpu usage when someone sends many ipv6 udp packages
Submitter	: Ernst Sj=C3=B6strand <ernstp-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-03-05 01:10 (2 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D30142
Subject		: Kernel Oops after hibernation
Submitter	: Willi Mann <foss-ml-pz1JH+IlyL4@public.gmane.org>
Date		: 2011-03-01 08:12 (6 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D30072
Subject		: USB-to-serial problems in 2.6.37.1+ (pl2303)
Submitter	:  <akwatts-DaQTI0RpDDMAvxtiuMwx3w@public.gmane.org>
Date		: 2011-02-28 12:39 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D30062
Subject		: Huge amounts of "HDIO_GET_IDENTITY failed for /dev/sr0" mess=
ages during boot
Submitter	: Bernd Eggink <monoped-mFg29aWZVEaELgA04lAiVw@public.gmane.org>
Date		: 2011-02-28 10:52 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D30032
Subject		: r8169: 60 seconds delay when resuming from suspend
Submitter	: Guillaume Ayoub <xovni-39ZsbGIQGT5GWvitb5QawA@public.gmane.org>
Date		: 2011-02-27 16:52 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D29992
Subject		: boot hang 2.6.37.1 regression w/ intel_idle and CONFIG_NO_HZ=
=3Dn - asus p7p55d le
Submitter	: De Ganseman Amaury <amaury.deganseman-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-02-27 10:38 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D29952
Subject		: btrfs as root filesystems hangs on mount after d863b50ab0133=
3659314c2034890cb76d9fdc3c7
Submitter	: Asbj=C3=B8rn Sannes <ace-8p7wLbfn+Bodnm+yROfE0A@public.gmane.org>
Date		: 2011-02-26 15:59 (9 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/d863b50ab01333659314c20=
34890cb76d9fdc3c7


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D29902
Subject		: System suspend failed after 1-2 successful resumes
Submitter	: Alex Terekhov <a.terekhov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-02-25 22:24 (10 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D29852
Subject		: 2.6.38-rc5: nfsd: page allocation failure. spinlock trylock =
failure on UP
Submitter	: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-02-21 20:33 (14 days old)
Message-ID	: <AANLkTi=3D14N_c_B7mLY0H8Dt8pte6C0mjFnVuC37e44Hs-JsoAwUIsXov1KXRcyAk9cg@public.gmane.org=
l.com>
References	: http://marc.info/?l=3Dlinux-netdev&m=3D129832042402668&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D29812
Subject		: Brightness levels too low on Dell Inspiron 13" Intel HD 4 Se=
ries
Submitter	: Niklas Schnelle <niklas-74wnUeZ+fLazQB+pC5nmwQ@public.gmane.org>
Date		: 2011-02-24 10:24 (11 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/951f3512dba5bd44cda3e5e=
e22b4b522e4bb09fb


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D29672
Subject		: [regression][ALSA][hda-conexant][2.6.38-rcX] external microp=
hone sound too quiet
Submitter	: Shawn Starr <shawn.starr-bJEeYj9oJeDQT0dZR+AlfA@public.gmane.org>
Date		: 2011-02-19 6:02 (16 days old)
Message-ID	: <474630.25335.qm-LGyaPT5kzbjzJNTqFNLFoaJ1FwRQo79cG6kzb5Gsg2M@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129809536502092&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D29312
Subject		: Unmounting fails even after the underlying device is long go=
ne
Submitter	: Bart Van Assche <bart.vanassche-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-02-17 19:20 (18 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D29252
Subject		: IPv6 doesn't work in a kvm guest.
Submitter	: Kusanagi Kouichi <slash-cQ3dDVBNB1RrxjOHzPOmfA@public.gmane.org>
Date		: 2011-02-16 13:03 (19 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D29022
Subject		: [REGRESSION? 2.6.38-rc4] nouveau NV50/NVA8 screen freeze
Submitter	: Marc Koschewski <marc-e1Wt+8K1Ta8ZEwqihLH0+Q@public.gmane.org>
Date		: 2011-02-13 12:29 (22 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28882
Subject		: Screen corruption and GPU hangs
Submitter	: Ko Mi <chaostya.test-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
Date		: 2011-02-11 18:17 (24 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28842
Subject		: 2.6.38-rc3 regression ipv6 TFTP download with curl failing i=
n getpeername?
Submitter	: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Date		: 2011-02-08 9:41 (27 days old)
Message-ID	: <m1ei7iamnn.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129715811421534&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28642
Subject		: ACPI broken on DELL Latitude E6410 in 2.6.38-rc3
Submitter	: Adam Kovari <kovariadam-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-02-08 22:22 (27 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28562
Subject		: [BUG] usb problems in .38-rc3+
Submitter	: Ed Tomlinson <edt-Yad3+ZauZac@public.gmane.org>
Date		: 2011-02-05 19:17 (30 days old)
Message-ID	: <201102051417.58953.edt-Yad3+ZauZac@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129693391417607&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28522
Subject		: Unable to mount FAT-formatted floppy on /dev/fd0, plus WARN_=
ON when using /dev/fd0u1440
Submitter	: Alex Villacis Lasso <avillaci-x0m+Mc+nT7uljOmnV8AmnkElSqmLX1BE@public.gmane.org>
Date		: 2011-02-07 17:21 (28 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28452
Subject		: 2.6.38-rc3 regression on parisc: segfaults
Submitter	: Meelis Roos <mroos-Y27EyoLml9s@public.gmane.org>
Date		: 2011-02-01 22:00 (34 days old)
Message-ID	: <alpine.SOC.1.00.1102012342200.25944-ptEonEWSGqKptlylMvRsHA@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129659763426600&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28432
Subject		: khugepaged: gets stuck when writing to USB flash, 2.6.38-rc2
Submitter	: Jind=C5=99ich Makovi=C4=8Dka <makovick-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-01-31 19:28 (35 days old)
Message-ID	: <AANLkTi=3DuOpN0PwWdGh6iri-vJwuMS+WMPxmaZjv0-TrV-JsoAwUIsXov1KXRcyAk9cg@public.gmane.org=
l.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129650210516627&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28422
Subject		: kref and apparmor panic in 2.6.38-rc2.
Submitter	: Tao Ma <tm-d1IQDZat3X0@public.gmane.org>
Date		: 2011-01-31 10:06 (35 days old)
Message-ID	: <4D46899B.80302-d1IQDZat3X0@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129646840303149&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28262
Subject		: Slow resume from suspend/hibernate on Dell Inspiron M301Z
Submitter	: Luca Ferretti <lferrett-rDKQcyrBJuzYtjvyW6yDsg@public.gmane.org>
Date		: 2011-02-05 12:37 (30 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28102
Subject		: New display errors in 2.6.38-rc2-00175-g6fb1b30
Submitter	: Nico Schottelius <nico-kernel-20110117-xuaVFQXs+5hIG4jRRZ66WA@public.gmane.org>
Date		: 2011-01-28 20:29 (38 days old)
Message-ID	: <20110128202905.GB3395-xuaVFQXs+5hIG4jRRZ66WA@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129624657425949&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D27022
Subject		: [REPORT] BUG: spinlock recursion on CPU#0, init/1
Submitter	: Santosh Shilimkar <santosh.shilimkar-l0cyMroinI0@public.gmane.org>
Date		: 2011-01-10 15:33 (56 days old)
Message-ID	: <a7a9bdaa5936630925fb7ffd1a1795b1-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129467294808655&w=3D=
2


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D29402
Subject		: kernel panics while running ffsb scalability workloads on 2.=
6.38-rc1 through -rc5
Submitter	: Eric Whitney <eric.whitney-VXdhtT5mjnY@public.gmane.org>
Date		: 2011-02-18 21:47 (17 days old)
Handled-By	: Lukas Czerner <lczerner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=3D49642


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.37,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D27352

Please let the tracking team know if there are any Bugzilla entries tha=
t
should be added to the list in there.

Thanks!
