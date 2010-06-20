From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.35-rc3: Reported regressions from 2.6.34
Date: Mon, 21 Jun 2010 00:11:54 +0200 (CEST)
Message-ID: <lc60d4toGTL.A.QzD._LpHMB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
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
for which there are no fixes in the mainline known to the tracking team.
If any of them have been fixed already, please let us know.

If you know of any other unresolved regressions from 2.6.34, please let us
know either and we'll add them to the list.  Also, please let us know
if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply
to this message with CCs to the people involved in reporting and handling
the issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2010-06-21       46       37          26
  2010-06-09       15       13          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16255
Subject		: 2.6.35-rc3 deadlocks on semaphore operations
Submitter	: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date		: 2010-06-18 14:49 (3 days old)
Message-ID	: <alpine.DEB.2.00.1006180940140.11575-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127687262727707&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16248
Subject		: inconsistent lock state
Submitter	: Sergey Senozhatsky <sergey.senozhatsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-15 11:24 (6 days old)
Message-ID	: <20100615112434.GA3967-dY8u8AhHFaWtd10JCjopabkcH5ONE+aC@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127660087625903&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16247
Subject		: drm/i915 BUG with 2.6.35-rc
Submitter	: Benny Halevy <bhalevy-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>
Date		: 2010-06-14 22:38 (7 days old)
Message-ID	: <4C16AF56.1040002-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127655510531367&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16235
Subject		: [REGRESSION] [IWL3945] Broadcast is broken?
Submitter	: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-14 17:24 (7 days old)
Message-ID	: <201006141924.24061.maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127653628301300&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16234
Subject		: [2.6.35-rc3] reboot mutex 'bug'...
Submitter	: Daniel J Blueman <daniel.blueman-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-14 15:16 (7 days old)
Message-ID	: <AANLkTimDcTnyEPmt2ZcCM1UWtn4AYKotiqyjobJApkO7-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127652861118933&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16232
Subject		: 2.6.35-rc3 - WARNING:iwl_set_dynamic_key
Submitter	: Mario Guenterberg <mario.guenterberg-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date		: 2010-06-14 11:55 (7 days old)
Message-ID	: <20100614115510.GA7904@guenti-laptop>
References	: http://marc.info/?l=linux-kernel&m=127651695627147&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16230
Subject		: inconsistent IN-HARDIRQ-W -> HARDIRQ-ON-W usage: fasync, 2.6.35-rc3
Submitter	: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
Date		: 2010-06-13 9:53 (8 days old)
Message-ID	: <20100613095305.GA13231-S7uyTPAaJ/sb6pqDj42GsMgv3T4z79SOrE5yTffgRl4@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127642282208277&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16228
Subject		: BUG/boot failure on Dell Precision T3500 (pci/ahci_stop_engine)
Submitter	: Brian Bloniarz <phunge0-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
Date		: 2010-06-16 17:57 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16222
Subject		: 2.6.35-rc{12} regression: inactive console corrupted
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2010-06-12 10:33 (9 days old)
Message-ID	: <20100612103321.GA1458-+ZI9xUNit7I@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127633882614501&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16221
Subject		: 2.6.35-rc2-git5 -- [drm:drm_mode_getfb] *ERROR* invalid framebuffer id
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-11 20:31 (10 days old)
Message-ID	: <AANLkTim0jVRyqkwlGOcrg_XTvUQwcBYfWJX-aRzkkrLG-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127628828119623&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16205
Subject		: acpi: freeing invalid memtype bf799000-bf79a000
Submitter	: Marcin Slusarz <marcin.slusarz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-09 20:09 (12 days old)
Message-ID	: <20100609200910.GA2876-OI9uyE9O0yo@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127611427029914&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16201
Subject		: SIOCGIWFREQ ioctl fails to get frequency info
Submitter	: nuh <nuh-hRtevi7K+EWJQ7yn63+t2w@public.gmane.org>
Date		: 2010-06-14 10:45 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16199
Subject		: 2.6.35-rc2-git1 - include/linux/cgroup.h:534 invoked rcu_dereference_check() without protection!
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-07 18:14 (14 days old)
Message-ID	: <AANLkTin2pPqOUx--9fIX3BH3e-cU6oCRufijcx_4ozx5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127593447812015&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16198
Subject		: Running make install over sshfs is painful now
Submitter	: Dmitry Torokhov <dmitry.torokhov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-07 6:53 (14 days old)
Message-ID	: <20100607065324.GA25590-WlK9ik9hQGAhIp7JRqBPierSzoNAToWh@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127589362011138&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16197
Subject		: [BUG on 2.6.35-rc2] sysfs: cannot create duplicate filename '/devices/pci0000:00/0000:00:11.0/0000:02:03.0/slot'
Submitter	: Ryan Wang <openspace.wang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-07 0:23 (14 days old)
Message-ID	: <AANLkTincwMZPnYW3S4uz4k2GOn52RpgBIBRfzyD010Yo-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127587022219378&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16184
Subject		: Container, X86-64, i386, iptables rule
Submitter	: Jean-Marc Pigeon <jmp-4qkeo2rQ0gg@public.gmane.org>
Date		: 2010-06-12 04:17 (9 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16179
Subject		: 2.6.35-rc2 completely hosed on intel gfx?
Submitter	: Norbert Preining <preining-DX+603jRYB8@public.gmane.org>
Date		: 2010-06-06 11:55 (15 days old)
Message-ID	: <20100606115534.GA9399-DqSSrKF0TaySnEC3TeqHn5dqbFPxfnh/@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127582534931581&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16178
Subject		: 2.6.35-rc2 : OOPS with LTP memcg regression test run.
Submitter	: Sachin Sant <sachinp-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
Date		: 2010-06-06 15:18 (15 days old)
Message-ID	: <4C0BB98E.9030101-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127583683912607&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16176
Subject		: Microcode errors with iwl3945
Submitter	: Steinar H. Gunderson <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Date		: 2010-06-10 19:28 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16175
Subject		: 2.6.35-rc1 system oom, many processes killed but memory not free
Submitter	: andrew hendry <andrew.hendry-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-05 0:46 (16 days old)
Message-ID	: <AANLkTim7CiW-yfugZUAHZCqLvXKgt9CwolCvbLGdCLAk-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127569877714937&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16173
Subject		: After uncompressing the kernel, at boot time, the server hangs.
Submitter	: David Hill <hilld-HTiBYHdybX7UkGsOFmftXw@public.gmane.org>
Date		: 2010-06-09 23:25 (12 days old)
First-Bad-Commit: http://git.kernel.org/linus/cf7500c0ea133d66f8449d86392d83f840102632


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16172
Subject		: 2.6.25-rc1 ahci regression
Submitter	: Luming Yu <luming.yu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-03 7:02 (18 days old)
First-Bad-Commit: http://git.kernel.org/linus/365cfa1ed5a36f9bcb9f64c9f0f52155af2e9fef
Message-ID	: <AANLkTikWak8i-Kaj-e-EUFWE66tfMmp2UPhGJCKkK1zK-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>>
References	: http://marc.info/?l=linux-kernel&m=127554855724361&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16160
Subject		: 2.6.35 Radeon KMS power management regression?
Submitter	: Nigel Cunningham <ncunningham-VWkGxi2CTS+6c6uEtOJ/EA@public.gmane.org>
Date		: 2010-06-01 6:23 (20 days old)
Message-ID	: <4C04A767.8000209-VWkGxi2CTS+6c6uEtOJ/EA@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127537343722290&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16145
Subject		: Unable to boot unless "notsc" or "clocksource=hpet", or acpi_pad disabling the TSC
Submitter	: Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>
Date		: 2010-06-07 13:11 (14 days old)
Handled-By	: Venkatesh Pallipadi <venki-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
		  Len Brown <lenb-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16122
Subject		: 2.6.35-rc1: WARNING at fs/fs-writeback.c:1142 __mark_inode_dirty+0x103/0x170
Submitter	: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Date		: 2010-06-04 13:18 (17 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16090
Subject		: sysfs: cannot create duplicate filename
Submitter	: Tobias <devnull-fBT1nhYaLZ4@public.gmane.org>
Date		: 2010-06-01 15:59 (20 days old)
Handled-By	: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16231
Subject		: Noticeable slow-down in 2.6.35-rc3
Submitter	: Chris Clayton <chris2553-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date		: 2010-06-13 20:15 (8 days old)
First-Bad-Commit: http://git.kernel.org/linus/597a264b1a9c7e36d1728f677c66c5c1f7e3b837
Message-ID	: <AANLkTimDUf0N6b5PBy2wTGeAWEIY-lUvQPHQ7D7Gyrq4-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127646015226601&w=2
Handled-By	: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Patch		: https://patchwork.kernel.org/patch/105859/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16220
Subject		: md/raid/udev fails to create md partition devices (/dev/mdXpY)
Submitter	: Duncan <1i5t5.duncan-j9pdmedNgrk@public.gmane.org>
Date		: 2010-06-15 17:19 (6 days old)
Handled-By	: Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>
Patch		: https://bugzilla.kernel.org/show_bug.cgi?id=16220#c2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16215
Subject		: sysfs: cannot create duplicate filename '/class/net/bnep0'
Submitter	: Janusz Krzysztofik <jkrzyszt-NCk8gXQAEuFz6jiHbVrK7g@public.gmane.org>
Date		: 2010-06-15 14:55 (6 days old)
Handled-By	: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Patch		: https://bugzilla.kernel.org/show_bug.cgi?id=16215#c10


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16196
Subject		: 2.6.35-rc2-git1 - WARNING: at net/wireless/mlme.c:341 cfg80211_send_assoc_timeout+0x107/0x11e [cfg80211]()
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-07 19:06 (14 days old)
Message-ID	: <AANLkTinmZh9GnrZLzOGi5Q_xHbky8cKdHAkOnsIA6_dZ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127593758817428&w=2
Handled-By	: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Patch		: http://marc.info/?l=linux-wireless&m=127608099427316&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16180
Subject		: radeon regression with 2.6.35-rc2-00001-g386f40c: black screen after resume
Submitter	: cedric <cedric-x1Cn44Nr1HaZIoH1IeqzKA@public.gmane.org>
Date		: 2010-06-11 10:59 (10 days old)
Handled-By	: Cedric Godin <cedric.godin-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=26733


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16169
Subject		: Complain from preemptive debug
Submitter	: Sedat Dilek <sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date		: 2010-05-31 10:10 (21 days old)
Message-ID	: <AANLkTilTnAAZIizKinYsxFkNTkrmPqk6XJJuUjjhJ7EP-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://lkml.org/lkml/2010/5/31/77
Handled-By	: Dmitry Monakhov <dmonakhov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Patch		: http://www.spinics.net/lists/cpufreq/msg01631.html


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16156
Subject		: No Sound with 2.6.34.x Kernel with my Audio-Chip
Submitter	: Ch: Hanisch <ch-hanisch-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
Date		: 2010-06-08 11:51 (13 days old)
Handled-By	: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=26724


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16131
Subject		: kernel BUG at fs/btrfs/extent-tree.c:4363 (btrfs_free_tree_block)
Submitter	: Chow Loong Jin <hyperair-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Date		: 2010-06-05 18:53 (16 days old)
Handled-By	: Yan Zheng <zheng.yan-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Patch		: https://patchwork.kernel.org/patch/103235/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16127
Subject		: Boot freeze on HP Compaq nx6325 (RS482) with Radeon KMS
Submitter	: Jure Repinc <jlp.bugs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-04 21:14 (17 days old)
Handled-By	: Dave Airlie <airlied-cv59FeDIM0c@public.gmane.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=26677


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16120
Subject		: Oops: 0000 [#1] SMP, unable to handle kernel NULL pointer dereference at (null)
Submitter	: Alex Zhavnerchik <alex.vizor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-04 09:25 (17 days old)
Handled-By	: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Patch		: https://bugzilla.kernel.org/show_bug.cgi?id=16120#c6


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16092
Subject		: Caught 64-bit read from uninitialized memory in memtype_rb_augment_cb
Submitter	: Christian Casteyde <casteyde.christian-GANU6spQydw@public.gmane.org>
Date		: 2010-06-01 18:08 (20 days old)
Handled-By	: Venki <venki-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Patch		: https://bugzilla.kernel.org/show_bug.cgi?id=16092#c2


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions from 2.6.34,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=16055

Please let the tracking team know if there are any Bugzilla entries that
should be added to the list in there.

Thanks!
