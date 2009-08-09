From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.31-rc5-git5: Reported regressions from 2.6.30
Date: Sun,  9 Aug 2009 22:36:49 +0200 (CEST)
Message-ID: <AuPdDySr74O.A.5LC.Pj1fKB@chimera>
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
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions from 2.6.30, for which=
 there
are no fixes in the mainline I know of.  If any of them have been fixed=
 already,
please let me know.

If you know of any other unresolved regressions from 2.6.30, please let=
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
  2009-08-10       89       27          24
  2009-08-02       76       36          28
  2009-07-27       70       51          43
  2009-07-07       35       25          21
  2009-06-29       22       22          15


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13950
Subject		: Oops when USB Serial disconnected while in use
Submitter	: Bruno Pr=C3=A9mont <bonbons@linux-vserver.org>
Date		: 2009-08-08 17:47 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124975432900466&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13947
Subject		: Libertas: Association request to the driver failed
Submitter	: Daniel Mack <daniel@caiaq.de>
Date		: 2009-08-07 19:11 (3 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D57921c312e8cef72ba35a4cfe870b376da0b1b87
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124967234311481&w=3D=
4
Handled-By	: Roel Kluin <roel.kluin@gmail.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13943
Subject		: WARNING: at net/mac80211/mlme.c:2292 with ath5k
Submitter	: Fabio Comolli <fabio.comolli@gmail.com>
Date		: 2009-08-06 20:15 (4 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124958978600600&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13942
Subject		: Troubles with AoE and uninitialized object
Submitter	: Bruno Pr=C3=A9mont <bonbons@linux-vserver.org>
Date		: 2009-08-04 10:12 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124938117104811&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13941
Subject		: x86 Geode issue
Submitter	: Martin-=C3=89ric Racine <q-funk@iki.fi>
Date		: 2009-08-03 12:58 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124930434732481&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13940
Subject		: iwlagn and sky2 stopped working, ACPI-related
Submitter	: Ricardo Jorge da Fonseca Marques Ferreira <storm@sys49152.n=
et>
Date		: 2009-08-07 22:33 (3 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124968457731107&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13935
Subject		: 2.6.31-rcX breaks Apple MightyMouse (Bluetooth version)
Submitter	: Adrian Ulrich <kernel@blinkenlights.ch>
Date		: 2009-08-08 22:08 (2 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dfa047e4f6fa63a6e9d0ae4d7749538830d14a343


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13914
Subject		: e1000e reports invalid NVM Checksum on 82566DM-2 (bisected)
Submitter	:  <jsbronder@gentoo.org>
Date		: 2009-08-04 18:06 (6 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13906
Subject		: Huawei E169 GPRS connection causes Ooops
Submitter	: Clemens Eisserer <linuxhippy@gmail.com>
Date		: 2009-08-04 09:02 (6 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13899
Subject		: Oops from tar, 2.6.31-rc5, 32 bit on quad core phenom.
Submitter	: Gene Heskett <gene.heskett@verizon.net>
Date		: 2009-08-01 13:04 (9 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124913190304149&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13895
Subject		: 2.6.31-rc4 - slab entry tak_delay_info leaking ???
Submitter	: Paul Rolland <rol@as2917.net>
Date		: 2009-07-29 08:20 (12 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124884847925375&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13869
Subject		: Radeon framebuffer (w/o KMS) corruption at boot.
Submitter	: Duncan <1i5t5.duncan@cox.net>
Date		: 2009-07-29 16:44 (12 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13848
Subject		: iwlwifi (4965) regression since 2.6.30
Submitter	: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Date		: 2009-07-26 7:57 (15 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124859658502866&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13846
Subject		: LEDs switched off permanently by power saving with rt61pci d=
river
Submitter	: Chris Clayton <chris2553@googlemail.com>
Date		: 2009-07-13 8:27 (28 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124747418828398&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13837
Subject		: Input : regression - touchpad not detected
Submitter	: Dave Young <hidave.darkstar@gmail.com>
Date		: 2009-07-17 07:13 (24 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124780763701571&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13836
Subject		: suspend script fails, related to stdout?
Submitter	: Tomas M. <tmezzadra@gmail.com>
Date		: 2009-07-17 21:24 (24 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124785853811667&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13833
Subject		: Kernel Oops when trying to suspend with ubifs mounted on blo=
ck2mtd mtd device
Submitter	: Tobias Diedrich <ranma@tdiedrich.de>
Date		: 2009-07-15 14:20 (26 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D15bce40cb3133bcc07d548013df97e4653d363c1
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124766049207807&w=3D=
4
		  http://marc.info/?l=3Dlinux-kernel&m=3D124704927819769&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13819
Subject		: system freeze when switching to console
Submitter	: Reinette Chatre <reinette.chatre@intel.com>
Date		: 2009-07-23 17:57 (18 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13809
Subject		: oprofile: possible circular locking dependency detected
Submitter	: Jerome Marchand <jmarchan@redhat.com>
Date		: 2009-07-22 13:35 (19 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13740
Subject		: X server crashes with 2.6.31-rc2 when options are changed
Submitter	: Michael S. Tsirkin <m.s.tsirkin@gmail.com>
Date		: 2009-07-07 15:19 (34 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13733
Subject		: 2.6.31-rc2: irq 16: nobody cared
Submitter	: Niel Lambrechts <niel.lambrechts@gmail.com>
Date		: 2009-07-06 18:32 (35 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124690524027166&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13716
Subject		: The AIC-7892P controller does not work any more
Submitter	: Andrej Podzimek <andrej@podzimek.org>
Date		: 2009-07-05 19:23 (36 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13713
Subject		: [drm/i915] Possible regression due to commit "Change GEM thr=
ottling to be 20ms (...)"
Submitter	:  <kazikcz@gmail.com>
Date		: 2009-07-05 10:49 (36 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Db962442e46a9340bdbc6711982c59ff0cc2b5afb


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13645
Subject		: NULL pointer dereference at (null) (level2_spare_pgt)
Submitter	: poornima nayak <mpnayak@linux.vnet.ibm.com>
Date		: 2009-06-17 17:56 (54 days old)
References	: http://lkml.org/lkml/2009/6/17/194


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13948
Subject		: ath5k broken after suspend-to-ram
Submitter	: Johannes Stezenbach <js@sig21.net>
Date		: 2009-08-07 21:51 (3 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124968192727854&w=3D=
4
Handled-By	: Nick Kossifidis <mickflemm@gmail.com>
Patch		: http://patchwork.kernel.org/patch/38550/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13946
Subject		: x86 MCE malfunction on Thinkpad T42p
Submitter	: Johannes Stezenbach <js@sig21.net>
Date		: 2009-08-07 17:09 (3 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124966500232399&w=3D=
4
Handled-By	: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Patch		: http://patchwork.kernel.org/patch/37908/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13944
Subject		: MD raid regression
Submitter	: Mike Snitzer <snitzer@redhat.com>
Date		: 2009-08-05 15:06 (5 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D449aad3e25358812c43afc60918c5ad3819488e7
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124948481218857&w=3D=
4
Handled-By	: NeilBrown <neilb@suse.de>
Patch		: http://patchwork.kernel.org/patch/39521/


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.30,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D13615

Please let me know if there are any Bugzilla entries that should be add=
ed to
the list in there.

Thanks,
Rafael

--
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
