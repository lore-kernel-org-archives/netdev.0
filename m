From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.35-rc6: Reported regressions from 2.6.34
Date: Fri, 23 Jul 2010 13:42:26 +0200 (CEST)
Message-ID: <Lupw7pePXBO.A.fZH.G2XSMB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
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
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions from 2.6.34,
for which there are no fixes in the mainline known to the tracking team=
=2E
If any of them have been fixed already, please let us know.

If you know of any other unresolved regressions from 2.6.34, please let=
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
  2010-07-23       94       33          25
  2010-07-09       79       45          37
  2010-06-21       46       37          26
  2010-06-09       15       13          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16423
Subject		: netfilter/iptables stopped logging 2.6.35-rc
Submitter	: auto401300-revL73yDgGBWk0Htik3J/w@public.gmane.org
Date		: 2010-07-17 10:20 (7 days old)
Message-ID	: <20100717072036.1BBE52804B-hP6SDYDcl0Dn1WiER8SD9wC/G2K4zDHf@public.gmane.org>
References	: http://lkml.indiana.edu/hypermail/linux/kernel/1007.2/0044=
0.html


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16406
Subject		: Badness with the kernel version 2.6.35-rc1-git1 running on P=
6 box
Submitter	: divya <dipraksh-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date		: 2010-07-16 8:50 (8 days old)
Message-ID	: <4C401D56.3070108-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127927024906085&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16405
Subject		: Brightness Adjustment on Toshiba nb305 Netbooks is non-funct=
ional.
Submitter	: John Mesmon <jmesmon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-07-15 23:40 (9 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/74a365b3f354fafc537efa5=
867deb7a9fadbfe27
Handled-By	: Matthew Garrett <mjg59-kernel-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16400
Subject		: 2.6.35-rc5 inconsistent lock state
Submitter	: Martin Pirker <lkml.collector-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-07-14 20:33 (10 days old)
Message-ID	: <AANLkTikDF0TL6OyPVCzPlUTwxFehcrETn3ysgSSeTq92-JsoAwUIsXotQFR93xxRIaA@public.gmane.org=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127913961025267&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16399
Subject		: perf failed with kernel 2.6.35-rc
Submitter	: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date		: 2010-07-13 8:14 (11 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/1ac62cfff252fb668405ef3=
398a1fa7f4a0d6d15
Message-ID	: <1279008849.2096.913.camel-sz7BYL/Y5Hu/P+R7jlPCFVaTQe2KTcn/@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127900880212470&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16393
Subject		: kernel BUG at fs/block_dev.c:765!
Submitter	: Markus Trippelsdorf <markus-xp2qqqlHh3xzoYq+O6RWwA@public.gmane.org>
Date		: 2010-07-14 13:52 (10 days old)
Message-ID	: <20100714135217.GA1797-joY5NpejW+Hx3b7vapvTcQ@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127911564213748&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16392
Subject		: BUG at arch/x86/mm/physaddr.c:5
Submitter	: Ortwin Gl=C3=BCck <odi-L693kI9kcNY@public.gmane.org>
Date		: 2010-07-14 6:54 (10 days old)
Message-ID	: <4C3D5F3F.7070901-L693kI9kcNY@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127909052705341&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16383
Subject		: Regression with e1000e from 2.6.34.1 to 2.6.35-rc5
Submitter	: Stefan Behte <craig-Iv0PAbYRtitM7kwft8N7nw@public.gmane.org>
Date		: 2010-07-14 00:44 (10 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16380
Subject		: Loop devices act strangely in 2.6.35
Submitter	: Artem S. Tashkinov <t.artem-VInPYn6yXxRWk0Htik3J/w@public.gmane.org>
Date		: 2010-07-13 23:21 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16372
Subject		: Regression 2.6.34->2.6.35-rc4: radeaon KMS an RS690 broken
Submitter	: Torsten Kaiser <just.for.lkml-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date		: 2010-07-11 19:56 (13 days old)
Message-ID	: <AANLkTimkNg81yzxSHTcAa1QlTE9SYmvzL4eOTVHApWq3-JsoAwUIsXotQFR93xxRIaA@public.gmane.org=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127887822407672&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16369
Subject		: Yet another 2.6.35 regression (AGP)?
Submitter	: Woody Suwalski <terraluna977-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-07-09 14:21 (15 days old)
Message-ID	: <4C373084.8000503-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127868797119254&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16365
Subject		: kernel BUG at fs/btrfs/extent-tree.c:1353
Submitter	: Johannes Hirte <johannes.hirte-3kN+8DYepx7zMJDuovMtMLNAH6kLmebB@public.gmane.org>
Date		: 2010-07-08 14:27 (16 days old)
Message-ID	: <201007081627.24654.johannes.hirte-3kN+8DYepx7zMJDuovMtMLNAH6kLmebB@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127859960725931&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16337
Subject		: general protection fault: 0000 [#1] SMP
Submitter	: Justin P. Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-07-03 22:59 (21 days old)
Message-ID	: <4C2FC0E3.6050101-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127819798215589&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16332
Subject		: Kernel crashes in tty code (tty_open)
Submitter	: werner-K1X7VnsBORrsrOwW+9ziJQ@public.gmane.org
Date		: 2010-07-02 3:34 (22 days old)
Message-ID	: <1278041650.12788-K1X7VnsBORrsrOwW+9ziJQ@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127804167511930&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16322
Subject		: WARNING: at /arch/x86/include/asm/processor.h:1005 read_meas=
ured_perf_ctrs+0x5a/0x70()
Submitter	: boris64 <bugzilla.kernel.org-ro/BP3KN3ujR7s880joybQ@public.gmane.org>
Date		: 2010-07-01 13:54 (23 days old)
Handled-By	: H. Peter Anvin <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16312
Subject		: WARNING: at fs/fs-writeback.c:1127 __mark_inode_dirty
Submitter	: Zdenek Kabelac <zdenek.kabelac-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-28 9:40 (26 days old)
Message-ID	: <AANLkTin24fr5O4_q5Xbo9Y_NKkEmtcp6Hgmr9_4qXaFz-JsoAwUIsXotQFR93xxRIaA@public.gmane.org=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127771804806465&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16311
Subject		: [REGRESSION][SUSPEND] 2.6.35-rcX won't suspend Lenovo W500 l=
aptop
Submitter	: Shawn Starr <shawn.starr-bJEeYj9oJeDQT0dZR+AlfA@public.gmane.org>
Date		: 2010-06-28 0:45 (26 days old)
Message-ID	: <<201006272045.17004.shawn.starr-bJEeYj9oJeDQT0dZR+AlfA@public.gmane.org>>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127768633705286&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16307
Subject		: i915 in kernel 2.6.35-rc3, high number of wakeups
Submitter	: Enrico Bandiello <enban-c0jvKHQHzSzx4jp4WZvp5g@public.gmane.org>
Date		: 2010-06-26 16:57 (28 days old)
Message-ID	: <4C26317A.5070309-c0jvKHQHzSzx4jp4WZvp5g@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127757403404259&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16265
Subject		: Why is kslowd accumulating so much CPU time?
Submitter	: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Date		: 2010-06-09 18:36 (45 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/fbf81762e385d3d45acad05=
7b654d56972acf58c
Message-ID	: <E1OMQ88-0002a1-Gb-UK71uKi2zisAobODsErMgNi2O/JbrIOy@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127610857819033&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16257
Subject		: sysfs changes break hwsim and bnep drivers
Submitter	: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date		: 2010-06-20 11:23 (34 days old)
References	: http://thread.gmane.org/gmane.linux.network/162754
Handled-By	: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
		  Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16228
Subject		: BUG/boot failure on Dell Precision T3500 (pci/ahci_stop_engi=
ne)
Submitter	: Brian Bloniarz <phunge0-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
Date		: 2010-06-16 17:57 (38 days old)
Handled-By	: Bjorn Helgaas <bjorn.helgaas-VXdhtT5mjnY@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16221
Subject		: 2.6.35-rc2-git5 -- [drm:drm_mode_getfb] *ERROR* invalid fram=
ebuffer id
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-11 20:31 (43 days old)
Message-ID	: <AANLkTim0jVRyqkwlGOcrg_XTvUQwcBYfWJX-aRzkkrLG-JsoAwUIsXotQFR93xxRIaA@public.gmane.org=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127628828119623&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16201
Subject		: SIOCGIWFREQ ioctl fails to get frequency info
Submitter	: nuh <nuh-hRtevi7K+EWJQ7yn63+t2w@public.gmane.org>
Date		: 2010-06-14 10:45 (40 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16184
Subject		: Container, X86-64, i386, iptables rule
Submitter	: Jean-Marc Pigeon <jmp-4qkeo2rQ0gg@public.gmane.org>
Date		: 2010-06-12 04:17 (42 days old)
Handled-By	: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16173
Subject		: After uncompressing the kernel, at boot time, the server han=
gs.
Submitter	: David Hill <hilld-HTiBYHdybX7UkGsOFmftXw@public.gmane.org>
Date		: 2010-06-09 23:25 (45 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/cf7500c0ea133d66f8449d8=
6392d83f840102632
Handled-By	: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16396
Subject		: [bisected] resume from suspend freezes system
Submitter	: tomas m <tmezzadra-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-07-15 02:32 (9 days old)
Handled-By	: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
Patch		: https://patchwork.kernel.org/patch/113108/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16353
Subject		: 2.6.35 regression
Submitter	: Zeev Tarantov <zeev.tarantov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-07-05 13:04 (19 days old)
Message-ID	: <loom.20100705T144459-919-eS7Uydv5nfjZ+VzJOa5vwg@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127836002702522&w=3D=
2
Handled-By	: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Patch		: https://patchwork.kernel.org/patch/110988/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16310
Subject		: arm omap invalid module format
Submitter	: Robert Nelson <robertcnelson-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-28 17:30 (26 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/d0679c730395d0bde9a4693=
9e7ba255b4ba7dd7c
Handled-By	: Michal Marek <mmarek-AlSwsSmVLrQ@public.gmane.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=3D26999


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16294
Subject		: [Q35 bisected] hang at init of i915 driver
Submitter	: Kees Cook <kees-oSa+0FWJbaXR7s880joybQ@public.gmane.org>
Date		: 2010-06-25 18:20 (29 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/f1befe71fa7a79ab733011b=
045639d8d809924ad
Handled-By	: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Patch		: https://patchwork.kernel.org/patch/111130/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16278
Subject		: lvm snapshot causes deadlock in 2.6.35
Submitter	: Phillip Susi <psusi-3tLf1voIkJTQT0dZR+AlfA@public.gmane.org>
Date		: 2010-06-23 16:55 (31 days old)
Handled-By	: Eric Sandeen <sandeen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=3D26933


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16271
Subject		: 2.6.35-rc3 regression: IBM Maia system is unbootable [ACPI r=
elated?]
Submitter	: James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Date		: 2010-06-21 16:03 (33 days old)
Message-ID	: <1277136189.10998.63.camel-0iu6Cu4xQGLYCGPCin2YbQ@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127713622821166&w=3D=
2
Handled-By	: Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Patch		: https://patchwork.kernel.org/patch/108497/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16256
Subject		: tpm_tis breaks suspend/hibernate on kernels > 2.6.34
Submitter	: Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date		: 2010-06-20 11:15 (34 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/225a9be24d799aa16d543c3=
1fb09f0c9ed1d9caa
Handled-By	: Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Patch		: http://marc.info/?l=3Dtpmdd-devel&m=3D127609160616162&w=3D2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16215
Subject		: sysfs: cannot create duplicate filename '/class/net/bnep0'
Submitter	: Janusz Krzysztofik <jkrzyszt-NCk8gXQAEuFz6jiHbVrK7g@public.gmane.org>
Date		: 2010-06-15 14:55 (39 days old)
Handled-By	: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Patch		: https://bugzilla.kernel.org/show_bug.cgi?id=3D16215#c10


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.34,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D16055

Please let the tracking team know if there are any Bugzilla entries tha=
t
should be added to the list in there.

Thanks!

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
