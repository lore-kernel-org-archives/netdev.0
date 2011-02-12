From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.38-rc4-git5: Reported regressions from 2.6.37
Date: Sat, 12 Feb 2011 23:57:33 +0100 (CET)
Message-ID: <NMZS1i37KEE.A.1eG.6_wVNB@chimera>
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
  2011-02-12       39       20          18
  2011-02-03       19       11           7


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28882
Subject		: Screen corruption and GPU hangs
Submitter	: Ko Mi <chaostya.test-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
Date		: 2011-02-11 18:17 (2 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28852
Subject		: [KMS] radeon artifacts when switched to graphics during boot
Submitter	: Old=C5=99ich Jedli=C4=8Dka <oldium.pro-9Vj9tDbzfuSlVyrhU4qvOw@public.gmane.org>
Date		: 2011-02-10 21:11 (3 days old)
Handled-By	: Alex Deucher <alexdeucher-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28842
Subject		: 2.6.38-rc3 regression ipv6 TFTP download with curl failing i=
n getpeername?
Submitter	: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Date		: 2011-02-08 9:41 (5 days old)
Message-ID	: <m1ei7iamnn.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129715811421534&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28832
Subject		: [regression][2.6.38-rcX][net][iwlagn] WiFi signal after peri=
od of time tanks causing contant drops
Submitter	: Shawn Starr <shawn.starr-bJEeYj9oJeDQT0dZR+AlfA@public.gmane.org>
Date		: 2011-02-07 3:54 (6 days old)
Message-ID	: <613373.34172.qm-3XllfvjizZ7zJNTqFNLFoaJ1FwRQo79cG6kzb5Gsg2M@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129705125832718&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28642
Subject		: ACPI broken on DELL Latitude E6410 in 2.6.38-rc3
Submitter	: Adam Kovari <kovariadam-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-02-08 22:22 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28562
Subject		: [BUG] usb problems in .38-rc3+
Submitter	: Ed Tomlinson <edt-Yad3+ZauZac@public.gmane.org>
Date		: 2011-02-05 19:17 (8 days old)
Message-ID	: <201102051417.58953.edt-Yad3+ZauZac@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129693391417607&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28522
Subject		: Unable to mount FAT-formatted floppy on /dev/fd0, plus WARN_=
ON when using /dev/fd0u1440
Submitter	: Alex Villacis Lasso <avillaci-x0m+Mc+nT7uljOmnV8AmnkElSqmLX1BE@public.gmane.org>
Date		: 2011-02-07 17:21 (6 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28452
Subject		: 2.6.38-rc3 regression on parisc: segfaults
Submitter	: Meelis Roos <mroos-Y27EyoLml9s@public.gmane.org>
Date		: 2011-02-01 22:00 (12 days old)
Message-ID	: <alpine.SOC.1.00.1102012342200.25944-ptEonEWSGqKptlylMvRsHA@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129659763426600&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28442
Subject		: 2.6.38-rc3: FUSE (sshfs) hangs under load
Submitter	: Dmitry Torokhov <dmitry.torokhov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-02-01 17:54 (12 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/4cd06a344db752f51343713=
8953af191cbe9a691
Message-ID	: <20110201175452.GB518-WlK9ik9hQGAhIp7JRqBPierSzoNAToWh@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129658291703679&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28432
Subject		: khugepaged: gets stuck when writing to USB flash, 2.6.38-rc2
Submitter	: Jind=C5=99ich Makovi=C4=8Dka <makovick-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-01-31 19:28 (13 days old)
Message-ID	: <AANLkTi=3DuOpN0PwWdGh6iri-vJwuMS+WMPxmaZjv0-TrV-JsoAwUIsXov1KXRcyAk9cg@public.gmane.org=
l.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129650210516627&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28422
Subject		: kref and apparmor panic in 2.6.38-rc2.
Submitter	: Tao Ma <tm-d1IQDZat3X0@public.gmane.org>
Date		: 2011-01-31 10:06 (13 days old)
Message-ID	: <4D46899B.80302-d1IQDZat3X0@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129646840303149&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28262
Subject		: Slow resume from suspend/hibernate on Dell Inspiron M301Z
Submitter	: Luca Ferretti <lferrett-rDKQcyrBJuzYtjvyW6yDsg@public.gmane.org>
Date		: 2011-02-05 12:37 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28232
Subject		: Kernel panics with 2.6.38 (rc1, rc2, rc3, rc4) and the lzo c=
ompression of btrfs
Submitter	: Juan Francisco Cantero Hurtado <iam-KGDpyYoRUt6ZuzBka8ofvg@public.gmane.org>
Date		: 2011-02-05 04:44 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28102
Subject		: New display errors in 2.6.38-rc2-00175-g6fb1b30
Submitter	: Nico Schottelius <nico-kernel-20110117-xuaVFQXs+5hIG4jRRZ66WA@public.gmane.org>
Date		: 2011-01-28 20:29 (16 days old)
Message-ID	: <20110128202905.GB3395-xuaVFQXs+5hIG4jRRZ66WA@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129624657425949&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28052
Subject		: [BUG] 2.6.38-rc2: Circular Locking Dependency
Submitter	: Knut Petersen <Knut_Petersen-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
Date		: 2011-01-24 9:25 (20 days old)
Message-ID	: <4D3D45A3.7040809-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129586118515443&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D27762
Subject		: Brightness Adjustment on Toshiba nb305 Netbooks is non-funct=
ional.
Submitter	: John Mesmon <jmesmon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-01-29 03:47 (15 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/44834a67c0082e2cf74b16b=
e91e49108b1432d65


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D27382
Subject		: ath5k phy0: gain calibration timeout
Submitter	: Nicolas Stransky <Nico-iEEwqw9Jamtfq8cQ1yknNg@public.gmane.org>
Date		: 2011-01-23 00:18 (21 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D27022
Subject		: [REPORT] BUG: spinlock recursion on CPU#0, init/1
Submitter	: Santosh Shilimkar <santosh.shilimkar-l0cyMroinI0@public.gmane.org>
Date		: 2011-01-10 15:33 (34 days old)
Message-ID	: <a7a9bdaa5936630925fb7ffd1a1795b1-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129467294808655&w=3D=
2


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28802
Subject		: commit 5d1d0cc breaks resume from suspend on Thinkpad X201
Submitter	: Bj=C3=B6rn Schlie=C3=9Fmann <chronoss-Mmb7MZpHnFY@public.gmane.org>
Date		: 2011-02-10 17:23 (3 days old)
Handled-By	: Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=3D47172


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D27702
Subject		: regression 2.6.37 -> 2.6.38-rc1: after suspend backlight can=
not be adjusted
Submitter	: Norbert Preining <preining-DX+603jRYB8@public.gmane.org>
Date		: 2011-01-21 1:55 (23 days old)
Message-ID	: <20110121015529.GD9796-DqSSrKF0TaySnEC3TeqHn5dqbFPxfnh/@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129557717826819&w=3D=
2
Handled-By	: Michael Karcher <kernel-53cgGKa3i4734X6bwOH/f4/+3M+ant7aZ+vKCSbpVNE@public.gmane.org>
Patch		: https://patchwork.kernel.org/patch/499221/


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
