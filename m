From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.28-rc8-git1: Reported regressions from 2.6.27
Date: Sat, 13 Dec 2008 17:29:48 +0100 (CET)
Message-ID: <u7kfEgp36eE.A.qpG.Y4_QJB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:40698 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750859AbYLMShT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 13:37:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This message contains a list of some regressions from 2.6.27, for which=
 there
are no fixes in the mainline I know of.  If any of them have been fixed=
 already,
please let me know.

If you know of any other unresolved regressions from 2.6.27, please let=
 me know
either and I'll add them to the list.  Also, please let me know if any =
of the
entries below are invalid.

Each entry from the list will be sent additionally in an automatic repl=
y to
this message with CCs to the people involved in reporting and handling =
the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2008-12-13      111       14          13
  2008-12-07      106       20          17
  2008-12-04      106       29          21
  2008-11-22       93       25          15
  2008-11-16       89       32          18
  2008-11-09       73       40          27
  2008-11-02       55       41          29
  2008-10-25       26       25          20


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12210
Subject		: 2.6.28-rc8 big regression in VM
Submitter	: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Date		: 2008-12-12 18:38 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122910711005135&w=3D=
4
Handled-By	: Wu Fengguang <fengguang.wu@intel.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12209
Subject		: oldish top core dumps (in its meminfo() function)
Submitter	: Andreas Mohr <andi@lisas.de>
Date		: 2008-12-12 18:49 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122910784006472&w=3D=
4
		  http://marc.info/?l=3Dlinux-kernel&m=3D122907511319288&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12208
Subject		: uml is very slow on 2.6.28 host
Submitter	: Miklos Szeredi <miklos@szeredi.hu>
Date		: 2008-12-12 9:35 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122907463518593&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12195
Subject		: "dd" make kernel panic
Submitter	: alexs <alex.shi@intel.com>
Date		: 2008-12-10 18:07 (4 days old)
Handled-By	: James Bottomley <James.Bottomley@HansenPartnership.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12178
Subject		: Xorg crash at first start
Submitter	: C=C3=A9dric Godin <cedric@belbone.be>
Date		: 2008-12-04 14:26 (10 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D52440211dcdc52c0b757f8b34d122e11b12cdd50
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122840082828098&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12160
Subject		: networking oops after resume from s2ram (2.6.28-rc6)
Submitter	: Marcin Slusarz <marcin.slusarz@gmail.com>
Date		: 2008-11-28 21:15 (16 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122790701615723&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12159
Subject		: 2.6.28-rc6-git1 -- No sound produced from Intel HDA ALSA dri=
ver
Submitter	: Miles Lane <miles.lane@gmail.com>
Date		: 2008-11-27 20:33 (17 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122781805620212&w=3D=
4
Handled-By	: Takashi Iwai <tiwai@suse.de>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12156
Subject		: v2.6.28-rc2: x86_32 relocation regression?
Submitter	: Vegard Nossum <vegard.nossum@gmail.com>
Date		: 2008-11-24 21:19 (20 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122756158220966&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12155
Subject		: Regression in 2.6.28-rc and 2.6.27-stable - hibernate relate=
d
Submitter	: Fabio Comolli <fabio.comolli@gmail.com>
Date		: 2008-11-23 16:17 (21 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122745709926361&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12100
Subject		: resume (S2R) broken by Intel microcode module, on A110L
Submitter	: Andreas Mohr <andi@lisas.de>
Date		: 2008-11-25 08:48 (19 days old)
Handled-By	: Dmitry Adamushko <dmitry.adamushko@gmail.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12061
Subject		: snd_hda_intel: power_save: sound cracks on powerdown
Submitter	: Jens Weibler <bugzilla-kernel@jensthebrain.de>
Date		: 2008-11-18 12:07 (26 days old)
Handled-By	: Takashi Iwai <tiwai@suse.de>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12028
Subject		: i915 DRM is broken in 2.6.28-rc4
Submitter	: Adam Tkac <vonsch@gmail.com>
Date		: 2008-11-14 01:50 (30 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11849
Subject		: default IRQ affinity change in v2.6.27 (breaking several SMP=
 PPC based systems)
Submitter	: Kumar Gala <galak@kernel.crashing.org>
Date		: 2008-10-24 12:45 (51 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122485245924125&w=3D=
4


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12047
Subject		: ACPI toshiba: only register rfkill if bt is enabled
Submitter	: Andrey Borzenkov <arvidjaar@mail.ru>
Date		: 2008-10-28 19:10 (47 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122522113619025&w=3D=
2
Handled-By	: Frederik Deweerdt <frederik.deweerdt@gmail.com>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122526843117478&w=3D2


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.27,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D11808

Please let me know if there are any Bugzilla entries that should be add=
ed to
the list in there.

Thanks,
Rafael

