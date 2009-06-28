From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.31-rc1-git3: Reported regressions from 2.6.30
Date: Mon, 29 Jun 2009 01:51:02 +0200 (CEST)
Message-ID: <ij4ZQY4URcP.A.F3B.vIASKB@chimera>
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
  2009-06-29       22       22          15


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13667
Subject		: drm: display arifacts when X.Org is stopped
Submitter	: Frans Pop <elendil@planet.nl>
Date		: 2009-06-27 18:52 (2 days old)
References	: http://lkml.org/lkml/2009/6/27/105


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13666
Subject		: WARNING: at mm/page_alloc.c:1743 __alloc_pages_nodemask
Submitter	: Thomas Meyer <thomas@m3y3r.de>
Date		: 2009-06-27 16:15 (2 days old)
References	: http://lkml.org/lkml/2009/6/27/75


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13661
Subject		: warning in smp_call_function_single while S2R
Submitter	: Thomas Meyer <thomas@m3y3r.de>
Date		: 2009-06-27 17:12 (2 days old)
References	: http://lkml.org/lkml/2009/6/27/80


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13657
Subject		: Linux-2.6.31-rc1 Fails To Recognize Some USB Disks
Submitter	: Tarkan Erimer <tarkan.erimer@turknet.net.tr>
Date		: 2009-06-26 10:03 (3 days old)
References	: http://lkml.org/lkml/2009/6/26/34


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13656
Subject		: 2.6.31-rc1 crashes randomly on my Machine.
Submitter	: Zeno Davatz <zdavatz@gmail.com>
Date		: 2009-06-26 08:56 (3 days old)
References	: http://lkml.org/lkml/2009/6/26/27


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13652
Subject		: scheduling while atomic: pptpgw
Submitter	: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Date		: 2009-06-19 21:15 (10 days old)
References	: http://lkml.org/lkml/2009/6/19/237


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13650
Subject		: Problem with alloc_arch_preferred_bootmem() on powerpc
Submitter	: Sean MacLennan <smaclennan@pikatech.com>
Date		: 2009-06-20 19:48 (9 days old)
References	: http://marc.info/?l=3Dlinuxppc-embedded&m=3D12455273241177=
5&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13645
Subject		: NULL pointer dereference at (null) (level2_spare_pgt)
Submitter	: poornima nayak <mpnayak@linux.vnet.ibm.com>
Date		: 2009-06-17 17:56 (12 days old)
References	: http://lkml.org/lkml/2009/6/17/194


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13643
Subject		: Touchpad lost synchronization after resume from suspend to R=
AM
Submitter	: Cijoml Cijomlovic Cijomlov <cijoml@volny.cz>
Date		: 2009-06-28 10:42 (1 days old)
References	: http://lkml.org/lkml/2009/6/23/365
		  http://lkml.org/lkml/2009/6/25/256


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13633
Subject		: [bisected] No sound on HDA Intel (ALC268)
Submitter	: Brian Rogers <brian@xyzw.org>
Date		: 2009-06-27 04:42 (2 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13627
Subject		: Tunnel device ignores TCP/UDP traffic
Submitter	: Paul Martin <pm@debian.org>
Date		: 2009-06-26 14:45 (3 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13610
Subject		: radeon kms invalid edid data at lvds
Submitter	: Nicolas Reinecke <pl4nkton@googlemail.com>
Date		: 2009-06-23 19:53 (6 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13601
Subject		: Hard crash connecting via Huawei E169 + umtsmon
Submitter	: Clemens Eisserer <linuxhippy@gmail.com>
Date		: 2009-06-22 13:58 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13592
Subject		: Root partition is not found
Submitter	: Fran=C3=A7ois Valenduc <francois.valenduc@tvcablenet.be>
Date		: 2009-06-21 08:42 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13522
Subject		: BUG: scheduling while atomic
Submitter	: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Date		: 2009-06-12 19:29 (17 days old)


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13665
Subject		: commit 69c854817566 causes OOMs
Submitter	: David Howells <dhowells@redhat.com>
Date		: 2009-06-27 08:12 (2 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D69c854817566db82c362797b4a6521d0b00fe1d8
References	: http://lkml.org/lkml/2009/6/27/28
Handled-By	: Wu Fengguang <fengguang.wu@intel.com>
Patch		: http://patchwork.kernel.org/patch/32740/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13662
Subject		: broken alpha smp build
Submitter	: maximilian attems <max@stro.at>
Date		: 2009-06-25 11:08 (4 days old)
References	: http://lkml.org/lkml/2009/6/25/108
Handled-By	: Tejun Heo <tj@kernel.org>
Patch		: http://patchwork.kernel.org/patch/32714/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13659
Subject		: iwlagn (4965): no wireless due to RFKILL problem
Submitter	: Frans Pop <elendil@planet.nl>
Date		: 2009-06-26 13:36 (3 days old)
References	: http://lkml.org/lkml/2009/6/26/127
Handled-By	: Johannes Berg <johannes@sipsolutions.net>
Patch		: http://lkml.org/lkml/2009/6/27/35


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13658
Subject		: parisc: multiple PCI BAR collisions
Submitter	: Alexander Beregalov <a.beregalov@gmail.com>
Date		: 2009-06-26 12:58 (3 days old)
References	: http://lkml.org/lkml/2009/6/26/87
Handled-By	: Matthew Wilcox <matthew@wil.cx>
Patch		: http://patchwork.kernel.org/patch/32593/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13655
Subject		: [Oops] 2.6.31-rc1: tun
Submitter	: Sergei Trofimovich <slyich@gmail.com>
Date		: 2009-06-25 23:53 (4 days old)
References	: http://lkml.org/lkml/2009/6/25/435
Handled-By	: Herbert Xu <herbert@gondor.apana.org.au>
Patch		: http://patchwork.kernel.org/patch/32672/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13654
Subject		: possible recursive locking detected at kmem_cache_free
Submitter	: Pallipadi, Venkatesh <venkatesh.pallipadi@intel.com>
Date		: 2009-06-25 11:59 (4 days old)
References	: http://lkml.org/lkml/2009/6/25/373
Handled-By	: Pekka J Enberg <penberg@cs.helsinki.fi>
Patch		: http://patchwork.kernel.org/patch/32525/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13653
Subject		: system hangs after resume from suspend to disk, mce related
Submitter	: Maciej Rutecki <maciej.rutecki@gmail.com>
Date		: 2009-06-21 19:02 (8 days old)
References	: http://lkml.org/lkml/2009/6/21/86
Handled-By	: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Patch		: http://patchwork.kernel.org/patch/32062/


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
