From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.35-rc4-git3: Reported regressions from 2.6.34
Date: Fri,  9 Jul 2010 01:33:37 +0200 (CEST)
Message-ID: <-IGZ64uxA6G.A.P0H.bLmNMB@chimera>
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
	DRI <dri-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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
  2010-07-09       79       45          37
  2010-06-21       46       37          26
  2010-06-09       15       13          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16353
Subject		: 2.6.35 regression
Submitter	: Zeev Tarantov <zeev.tarantov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-07-05 13:04 (4 days old)
Message-ID	: <loom.20100705T144459-919-eS7Uydv5nfjZ+VzJOa5vwg@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127836002702522&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16346
Subject		: 2.6.35-rc3-git8 - include/linux/fdtable.h:88 invoked rcu_der=
eference_check() without protection!
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-07-04 22:04 (5 days old)
Message-ID	: <AANLkTinof0k28rk4rMr66aubxcRL2rFa5ZEArj1lqD3o-JsoAwUIsXotQFR93xxRIaA@public.gmane.org=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127828107815930&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16337
Subject		: general protection fault: 0000 [#1] SMP
Submitter	: Justin P. Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-07-03 22:59 (6 days old)
Message-ID	: <4C2FC0E3.6050101-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127819798215589&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16334
Subject		: reiserfs locking (v2)
Submitter	: Sergey Senozhatsky <sergey.senozhatsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-07-02 9:34 (7 days old)
Message-ID	: <20100702093451.GA3973-dY8u8AhHFaWtd10JCjopabkcH5ONE+aC@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127806306303590&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16333
Subject		: iwl3945: HARDWARE GONE??
Submitter	: Priit Laes <plaes-q/aMd4JkU83YtjvyW6yDsg@public.gmane.org>
Date		: 2010-07-02 16:02 (7 days old)
Message-ID	: <1278086575.2889.8.camel@chi>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127808659705983&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16332
Subject		: Kernel crashes in tty code (tty_open)
Submitter	: werner-K1X7VnsBORrsrOwW+9ziJQ@public.gmane.org
Date		: 2010-07-02 3:34 (7 days old)
Message-ID	: <1278041650.12788-K1X7VnsBORrsrOwW+9ziJQ@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127804167511930&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16330
Subject		: Dynamic Debug broken on 2.6.35-rc3?
Submitter	: Thomas Renninger <trenn-l3A5Bk7waGM@public.gmane.org>
Date		: 2010-07-01 15:44 (8 days old)
Message-ID	: <201007011744.19564.trenn-l3A5Bk7waGM@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127799907218877&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16329
Subject		: 2.6.35-rc3: Load average climbing to 3+ with no apparent rea=
son: CPU 98% idle, with hardly no I/O
Submitter	: T=C3=B6r=C3=B6k Edwin <edwintorok-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-07-01 7:40 (8 days old)
Message-ID	: <20100701104022.404410d6@debian>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127797005030536&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16324
Subject		: Oops while running fs_racer test on a POWER6 box against lat=
est git
Submitter	: divya <dipraksh-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date		: 2010-06-30 11:34 (9 days old)
Message-ID	: <4C2B28F3.7000006-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127789697303061&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16323
Subject		: 2.6.35-rc3-git4 - kernel/sched.c:616 invoked rcu_dereference=
_check() without protection!
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-07-01 12:21 (8 days old)
Message-ID	: <AANLkTini6hz2LFeZi8CMUmY3xw1MU7NxmyesuxZ4oCdo-JsoAwUIsXotQFR93xxRIaA@public.gmane.org=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127798693125541&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16322
Subject		: WARNING: at /arch/x86/include/asm/processor.h:1005 read_meas=
ured_perf_ctrs+0x5a/0x70()
Submitter	: boris64 <bugzilla.kernel.org-ro/BP3KN3ujR7s880joybQ@public.gmane.org>
Date		: 2010-07-01 13:54 (8 days old)
Handled-By	: H. Peter Anvin <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16312
Subject		: WARNING: at fs/fs-writeback.c:1127 __mark_inode_dirty
Submitter	: Zdenek Kabelac <zdenek.kabelac-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-28 9:40 (11 days old)
Message-ID	: <AANLkTin24fr5O4_q5Xbo9Y_NKkEmtcp6Hgmr9_4qXaFz-JsoAwUIsXotQFR93xxRIaA@public.gmane.org=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127771804806465&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16311
Subject		: [REGRESSION][SUSPEND] 2.6.35-rcX won't suspend Lenovo W500 l=
aptop
Submitter	: Shawn Starr <shawn.starr-bJEeYj9oJeDQT0dZR+AlfA@public.gmane.org>
Date		: 2010-06-28 0:45 (11 days old)
Message-ID	: <201006272045.17004.shawn.starr-bJEeYj9oJeDQT0dZR+AlfA@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127768633705286&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16309
Subject		: 2.6.35-rc3 oops trying to suspend.
Submitter	: Andrew Hendry <andrew.hendry-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-27 12:40 (12 days old)
Message-ID	: <AANLkTinUH2p33-AWxOVDrLsNkn9rgEVrlwn5mfK7P8NH-JsoAwUIsXotQFR93xxRIaA@public.gmane.org=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127764249926781&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16307
Subject		: i915 in kernel 2.6.35-rc3, high number of wakeups
Submitter	: Enrico Bandiello <enban-c0jvKHQHzSzx4jp4WZvp5g@public.gmane.org>
Date		: 2010-06-26 16:57 (13 days old)
Message-ID	: <4C26317A.5070309-c0jvKHQHzSzx4jp4WZvp5g@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127757403404259&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16306
Subject		: 2.6.35-rc3 BUG: unable to handle kernel NULL pointer derefer=
ence at 0000000000000048 cifs_show_options
Submitter	: Andrew Hendry <andrew.hendry-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-26 10:46 (13 days old)
Message-ID	: <AANLkTilhTrEBYZd4HxeXQk8B6-yV8rCJ2C0jXsEREgIR-JsoAwUIsXotQFR93xxRIaA@public.gmane.org=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127754922110501&w=3D=
2
Handled-By	: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16304
Subject		: i915 - high number of wakeups
Submitter	: Enrico Bandiello <enban-c0jvKHQHzSzx4jp4WZvp5g@public.gmane.org>
Date		: 2010-06-27 09:52 (12 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16294
Subject		: [Q35 bisected] hang at init of i915 driver
Submitter	: Kees Cook <kees-oSa+0FWJbaXR7s880joybQ@public.gmane.org>
Date		: 2010-06-25 18:20 (14 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/f1befe71fa7a79ab733011b=
045639d8d809924ad


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16288
Subject		: kernel panic with iwlagn for Intel Wifi Link 5100
Submitter	:  <yanshuang.zheng-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-25 08:14 (14 days old)
Handled-By	: Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16284
Subject		: Hitting WARN_ON in hw_breakpoint code
Submitter	: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
Date		: 2010-06-23 12:57 (16 days old)
Message-ID	: <20100623125740.GA3368-oklZEfemRj05kJ7NmlRacFaTQe2KTcn/@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127729789113432&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16265
Subject		: Why is kslowd accumulating so much CPU time?
Submitter	: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Date		: 2010-06-09 18:36 (30 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/fbf81762e385d3d45acad05=
7b654d56972acf58c
Message-ID	: <E1OMQ88-0002a1-Gb-UK71uKi2zisAobODsErMgNi2O/JbrIOy@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127610857819033&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16257
Subject		: sysfs changes break hwsim and bnep drivers
Submitter	: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date		: 2010-06-20 11:23 (19 days old)
References	: http://thread.gmane.org/gmane.linux.network/162754
Handled-By	: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
		  Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16234
Subject		: [2.6.35-rc3] reboot mutex 'bug'...
Submitter	: Daniel J Blueman <daniel.blueman-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-14 15:16 (25 days old)
Message-ID	: <AANLkTimDcTnyEPmt2ZcCM1UWtn4AYKotiqyjobJApkO7-JsoAwUIsXotQFR93xxRIaA@public.gmane.org=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127652861118933&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16230
Subject		: inconsistent IN-HARDIRQ-W -> HARDIRQ-ON-W usage: fasync, 2.6=
=2E35-rc3
Submitter	: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
Date		: 2010-06-13 9:53 (26 days old)
Message-ID	: <20100613095305.GA13231-S7uyTPAaJ/sb6pqDj42GsMgv3T4z79SOrE5yTffgRl4@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127642282208277&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16228
Subject		: BUG/boot failure on Dell Precision T3500 (pci/ahci_stop_engi=
ne)
Submitter	: Brian Bloniarz <phunge0-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
Date		: 2010-06-16 17:57 (23 days old)
Handled-By	: Bjorn Helgaas <bjorn.helgaas-VXdhtT5mjnY@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16221
Subject		: 2.6.35-rc2-git5 -- [drm:drm_mode_getfb] *ERROR* invalid fram=
ebuffer id
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-11 20:31 (28 days old)
Message-ID	: <AANLkTim0jVRyqkwlGOcrg_XTvUQwcBYfWJX-aRzkkrLG-JsoAwUIsXotQFR93xxRIaA@public.gmane.org=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127628828119623&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16205
Subject		: acpi: freeing invalid memtype bf799000-bf79a000
Submitter	: Marcin Slusarz <marcin.slusarz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-09 20:09 (30 days old)
Message-ID	: <20100609200910.GA2876-OI9uyE9O0yo@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127611427029914&w=3D=
2
		  http://marc.info/?l=3Dlinux-kernel&m=3D127688398513862&w=3D2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16201
Subject		: SIOCGIWFREQ ioctl fails to get frequency info
Submitter	: nuh <nuh-hRtevi7K+EWJQ7yn63+t2w@public.gmane.org>
Date		: 2010-06-14 10:45 (25 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16199
Subject		: 2.6.35-rc2-git1 - include/linux/cgroup.h:534 invoked rcu_der=
eference_check() without protection!
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-07 18:14 (32 days old)
Message-ID	: <AANLkTin2pPqOUx--9fIX3BH3e-cU6oCRufijcx_4ozx5-JsoAwUIsXotQFR93xxRIaA@public.gmane.org=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127593447812015&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16197
Subject		: [BUG on 2.6.35-rc2] sysfs: cannot create duplicate filename =
'/devices/pci0000:00/0000:00:11.0/0000:02:03.0/slot'
Submitter	: Ryan Wang <openspace.wang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-07 0:23 (32 days old)
Message-ID	: <AANLkTincwMZPnYW3S4uz4k2GOn52RpgBIBRfzyD010Yo-JsoAwUIsXotQFR93xxRIaA@public.gmane.org=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127587022219378&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16187
Subject		: Carrier detection failed in dhcpcd when link is up
Submitter	: Christian Casteyde <casteyde.christian-GANU6spQydw@public.gmane.org>
Date		: 2010-06-12 15:15 (27 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/10708f37ae729baba9b67bd=
134c3720709d4ae62
Handled-By	: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16184
Subject		: Container, X86-64, i386, iptables rule
Submitter	: Jean-Marc Pigeon <jmp-4qkeo2rQ0gg@public.gmane.org>
Date		: 2010-06-12 04:17 (27 days old)
Handled-By	: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16179
Subject		: 2.6.35-rc2 completely hosed on intel gfx?
Submitter	: Norbert Preining <preining-DX+603jRYB8@public.gmane.org>
Date		: 2010-06-06 11:55 (33 days old)
Message-ID	: <20100606115534.GA9399-DqSSrKF0TaySnEC3TeqHn5dqbFPxfnh/@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127582534931581&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16175
Subject		: 2.6.35-rc1 system oom, many processes killed but memory not =
free
Submitter	: andrew hendry <andrew.hendry-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-05 0:46 (34 days old)
Message-ID	: <AANLkTim7CiW-yfugZUAHZCqLvXKgt9CwolCvbLGdCLAk-JsoAwUIsXotQFR93xxRIaA@public.gmane.org=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127569877714937&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16173
Subject		: After uncompressing the kernel, at boot time, the server han=
gs.
Submitter	: David Hill <hilld-HTiBYHdybX7UkGsOFmftXw@public.gmane.org>
Date		: 2010-06-09 23:25 (30 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/cf7500c0ea133d66f8449d8=
6392d83f840102632
Handled-By	: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16145
Subject		: Unable to boot unless "notsc" or "clocksource=3Dhpet", or ac=
pi_pad disabling the TSC
Submitter	: Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>
Date		: 2010-06-07 13:11 (32 days old)
Handled-By	: Venkatesh Pallipadi <venki-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
		  Len Brown <lenb-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16122
Subject		: 2.6.35-rc1: WARNING at fs/fs-writeback.c:1142 __mark_inode_d=
irty+0x103/0x170
Submitter	: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Date		: 2010-06-04 13:18 (35 days old)
Handled-By	: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16310
Subject		: arm omap invalid module format
Submitter	: Robert Nelson <robertcnelson-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-28 17:30 (11 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/d0679c730395d0bde9a4693=
9e7ba255b4ba7dd7c
Handled-By	: Michal Marek <mmarek-AlSwsSmVLrQ@public.gmane.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=3D26999


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16278
Subject		: lvm snapshot causes deadlock in 2.6.35
Submitter	: Phillip Susi <psusi-3tLf1voIkJTQT0dZR+AlfA@public.gmane.org>
Date		: 2010-06-23 16:55 (16 days old)
Handled-By	: Eric Sandeen <sandeen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=3D26933


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16271
Subject		: 2.6.35-rc3 regression: IBM Maia system is unbootable [ACPI r=
elated?]
Submitter	: James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Date		: 2010-06-21 16:03 (18 days old)
Message-ID	: <1277136189.10998.63.camel-0iu6Cu4xQGLYCGPCin2YbQ@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127713622821166&w=3D=
2
Handled-By	: Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Patch		: https://patchwork.kernel.org/patch/108497/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16256
Subject		: tpm_tis breaks suspend/hibernate on kernels > 2.6.34
Submitter	: Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date		: 2010-06-20 11:15 (19 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/225a9be24d799aa16d543c3=
1fb09f0c9ed1d9caa
Handled-By	: Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Patch		: http://marc.info/?l=3Dtpmdd-devel&m=3D127609160616162&w=3D2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16255
Subject		: 2.6.35-rc3 deadlocks on semaphore operations
Submitter	: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date		: 2010-06-18 14:49 (21 days old)
Message-ID	: <alpine.DEB.2.00.1006180940140.11575-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127687262727707&w=3D=
2
Handled-By	: Manfred Spraul <manfred-nhLOkwUX5cPe2c5cEj3t2g@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D127731055203402&w=3D2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16232
Subject		: 2.6.35-rc3 - WARNING:iwl_set_dynamic_key
Submitter	: Mario Guenterberg <mario.guenterberg-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date		: 2010-06-14 11:55 (25 days old)
Message-ID	: <20100614115510.GA7904@guenti-laptop>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127651695627147&w=3D=
2
Handled-By	: Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Patch		: http://article.gmane.org/gmane.linux.kernel.wireless.general/5=
2893


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16215
Subject		: sysfs: cannot create duplicate filename '/class/net/bnep0'
Submitter	: Janusz Krzysztofik <jkrzyszt-NCk8gXQAEuFz6jiHbVrK7g@public.gmane.org>
Date		: 2010-06-15 14:55 (24 days old)
Handled-By	: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Patch		: https://bugzilla.kernel.org/show_bug.cgi?id=3D16215#c10


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16169
Subject		: Complain from preemptive debug
Submitter	: Sedat Dilek <sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date		: 2010-05-31 10:10 (39 days old)
Message-ID	: <AANLkTilTnAAZIizKinYsxFkNTkrmPqk6XJJuUjjhJ7EP-JsoAwUIsXotQFR93xxRIaA@public.gmane.org=
com>
References	: http://lkml.org/lkml/2010/5/31/77
Handled-By	: Dmitry Monakhov <dmonakhov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
		  Sergey Senozhatsky <sergey.senozhatsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Patch		: http://www.spinics.net/lists/cpufreq/msg01631.html
		  https://patchwork.kernel.org/patch/106555/


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
