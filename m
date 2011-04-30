From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.39-rc5-git4: Reported regressions from 2.6.38
Date: Sat, 30 Apr 2011 21:42:11 +0200 (CEST)
Message-ID: <Xp4OiTz83N.A.O0D.JVGvNB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
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

[NOTE:
 I have one request for whoever works on fixing the listed regressions.  While
 your work is highly appreciated anyway, if you have a patch fixing a listed
 regression or you know of a commit fixing a listed regression, please drop
 a notice into the corresponding Bugzilla entry.  This will help us a lot.]  

This message contains a list of some regressions from 2.6.38,
for which there are no fixes in the mainline known to the tracking team.
If any of them have been fixed already, please let us know.

If you know of any other unresolved regressions from 2.6.38, please let us
know either and we'll add them to the list.  Also, please let us know
if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply
to this message with CCs to the people involved in reporting and handling
the issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2011-04-30       38       17          16
  2011-04-17       17       11          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=34012
Subject		: 2.6.39-rc4+: oom-killer busy killing tasks
Submitter	: Christian Kujau <lists-AanptEQQ3TL9uQeqpI+JUg@public.gmane.org>
Date		: 2011-04-22 1:57 (9 days old)
Message-ID	: <alpine.DEB.2.01.1104211841510.18728-yMVncJ7Z0T9hhup4ARC/jw@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=130343744622331&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=34002
Subject		: [REGRESSION] [2.6.39-rc3] Wrong resolution in framebuffer and X Window
Submitter	: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-04-17 16:04 (14 days old)
Message-ID	: <201104171804.04664.maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
References	: http://marc.info/?l=linux-fbdev&m=130305625114863&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33842
Subject		: NULL pointer dereference in ip_fragment
Submitter	: Tomas Carnecky <tom-ix/z9KG6G0Jl57MIdRCFDg@public.gmane.org>
Date		: 2011-04-23 07:51 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33812
Subject		: radeon with modeset option causes oops as secondary adapter (vgaswitcheroo)
Submitter	: Johannes Engel <jcnengel-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date		: 2011-04-21 23:14 (10 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33792
Subject		: lockdep trace when unplugging usb audio (.39rc4)
Submitter	: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date		: 2011-04-19 18:07 (12 days old)
Message-ID	: <20110419180745.GA438-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=130323648920431&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33492
Subject		: [bug] 2.6.39-rc3 fails to boot on Alpha
Submitter	: Mikael Pettersson <mikpe-1zs4UD6AkMk@public.gmane.org>
Date		: 2011-04-17 15:13 (14 days old)
Message-ID	: <19883.912.266127.538215-tgku4HJDRZih8lFjZTKsyTAV6s6igYVG@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=130305321212360&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33482
Subject		: [Regression] Bluetooth pairing does not work anymore in 2.6.39-rc3 (works in 2.6.38.3)
Submitter	: Gottfried Haider <gottfried.haider-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-04-16 16:38 (15 days old)
Message-ID	: <BANLkTi=LvyZ+7BHfVL849pztfvsYaVM4SQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=130297197128328&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33432
Subject		: WARNING at libata-core.c:5015 in 2.6.39-rc3-wl+, then lockup.
Submitter	: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Date		: 2011-04-13 16:29 (18 days old)
Message-ID	: <4DA5CF81.4070908-my8/4N5VtI7c+919tysfdA@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=130271220809443&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33422
Subject		: oops in radeon_ddc_get_modes on first boot of rc3
Submitter	: Steve French <smfrench-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-04-12 17:54 (19 days old)
Message-ID	: <BANLkTikTVuV9eH4GiLDs0DewGJXo_3daeg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=130263086322702&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33402
Subject		: [regression] 2.6.39-rc[1-3] fail to boot on G5 PowerMac
Submitter	: Mikael Pettersson <mikpe-1zs4UD6AkMk@public.gmane.org>
Date		: 2011-04-12 17:30 (19 days old)
Message-ID	: <19876.35918.322649.256455-tgku4HJDRZih8lFjZTKsyTAV6s6igYVG@public.gmane.org>
References	: http://marc.info/?l=linuxppc-embedded&m=130263128523237&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33302
Subject		: ACPI reboot broken on HP Compaq nx7300.
Submitter	: Alexey Zaytsev <alexey.zaytsev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-04-15 14:44 (16 days old)
First-Bad-Commit: http://git.kernel.org/linus/3d35ac346e981162eeba391e496faceed4753e7b


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33272
Subject		: drm related hard-hang
Submitter	: Peter Teoh <htmldeveloper-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-04-14 01:29 (17 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33242
Subject		: Lockdep splat in autofs with 2.6.39-rc2
Submitter	: Nick Bowler <nbowler-7BP4RkwGw0uXmMXjJBpWqg@public.gmane.org>
Date		: 2011-04-07 19:44 (24 days old)
Message-ID	: <20110407194403.GA29404-7BP4RkwGw0uXmMXjJBpWqg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=130220545614682&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33142
Subject		: 2.6.39-rc2 regression: X201s fails to resume b77dcf8460ae57d4eb9fd3633eb4f97b8fb20716
Submitter	: Keith Packard <keithp-aN4HjG94KOLQT0dZR+AlfA@public.gmane.org>
Date		: 2011-04-06 7:44 (25 days old)
Message-ID	: <yun1v1fj024.fsf-XEHByDMaNQOz9DMzp4kqnw@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=130207593728273&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33092
Subject		: [regression] 2.6.39-rc1 - Beagleboard usbnet broken
Submitter	: Mark Jackson <mpfj-list-kZtEnBLzDKq1Qrn1Bg8BZw@public.gmane.org>
Date		: 2011-04-04 9:22 (27 days old)
First-Bad-Commit: http://git.kernel.org/linus/087809fce28f50098d9c3ef1a6865c722f23afd2
Message-ID	: <4D998DC9.3040109-kZtEnBLzDKq1Qrn1Bg8BZw@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=130191386508831&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=32982
Subject		: Kernel locks up a few minutes after boot
Submitter	: Bart Van Assche <bart.vanassche-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-04-10 19:55 (21 days old)


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33802
Subject		: list_del corruption in sd driver since 2.6.39-rc4
Submitter	: Christian Casteyde <casteyde.christian-GANU6spQydw@public.gmane.org>
Date		: 2011-04-21 21:10 (10 days old)
Handled-By	: James Bottomley <James.Bottomley-l3A5Bk7waGM@public.gmane.org>
Patch		: http://marc.info/?l=linux-kernel&m=130271409412095


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions from 2.6.38,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=32012

Please let the tracking team know if there are any Bugzilla entries that
should be added to the list in there.

Thanks!
