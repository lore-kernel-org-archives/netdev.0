From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.29-rc2-git1: Reported regressions from 2.6.28
Date: Mon, 19 Jan 2009 22:28:08 +0100 (CET)
Message-ID: <0GOi9pntEoL.A.iGF.B9QdJB@chimera>
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
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions from 2.6.28, for which=
 there
are no fixes in the mainline I know of.  If any of them have been fixed=
 already,
please let me know.

If you know of any other unresolved regressions from 2.6.28, please let=
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
  2009-01-20       38       35          27
  2009-01-11       13       13          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12511
Subject		: WARNING: at drivers/dma/dmaengine.c:352
Submitter	: Ingo Molnar <mingo@elte.hu>
Date		: 2009-01-19 21:31 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123240070614443&w=3D=
4
Handled-By	: Dan Williams <dan.j.williams@intel.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12510
Subject		: 2.6.29-rc2 dies on startup
Submitter	: Ferenc Wagner <wferi@niif.hu>
Date		: 2009-01-19 12:53 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123236969321703&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12508
Subject		: "powerpc/pci: Reserve legacy regions on PCI" broke my G3
Submitter	: Mikael Pettersson <mikpe@it.uu.se>
Date		: 2009-01-17 22:46 (3 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dc1f343028d35ba4e88cd4a3c44e0d8b8a84264ee
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123223247325452&w=3D=
4
Handled-By	: Benjamin Herrenschmidt <benh@kernel.crashing.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12507
Subject		: e100: netconsole not functional because of missing firmware
Submitter	: Andrey Borzenkov <arvidjaar@mail.ru>
Date		: 2009-01-17 16:08 (3 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123220854426857&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12506
Subject		: Undefined symbols when CONFIG_MFD_PCF50633 is enabled
Submitter	: Ozan =C3=87a=C4=9Flayan <ozan@pardus.org.tr>
Date		: 2009-01-17 10:56 (3 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123218991104592&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12505
Subject		: 2.6.29-rc1 Firefox crashing on page load
Submitter	: Justin Madru <jdm64@gawab.com>
Date		: 2009-01-16 20:56 (4 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123213941914274&w=3D=
4
Handled-By	: Justin P. Mattock <justinmattock@gmail.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12504
Subject		: 2.6.29-rc1 vs selinux
Submitter	: Gene Heskett <gene.heskett@gmail.com>
Date		: 2009-01-16 8:21 (4 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123209412832287&w=3D=
4
Handled-By	: Stephen Smalley <sds@tycho.nsa.gov>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12503
Subject		: [slab corruption] BUG key_jar: Poison overwritten
Submitter	: Ingo Molnar <mingo@elte.hu>
Date		: 2009-01-15 18:16 (5 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123204353425825&w=3D=
4
Handled-By	: David Howells <dhowells@redhat.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12502
Subject		: pipe_read oops on sh
Submitter	: Adrian McMenamin <lkmladrian@gmail.com>
Date		: 2009-01-15 9:48 (5 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123201298005600&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12501
Subject		: build bug in eeepc-laptop.c
Submitter	: Ingo Molnar <mingo@elte.hu>
Date		: 2009-01-14 17:25 (6 days old)
References	: http://lkml.org/lkml/2009/1/14/315


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12499
Subject		: Problem with using bluetooth adaper connected to usb port
Submitter	: Maciej Rutecki <maciej.rutecki@gmail.com>
Date		: 2009-01-13 18:34 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123187185426236&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12498
Subject		: OOPS and panic on 2.6.29-rc1 on xen-x86
Submitter	: Bryan Donlan <bdonlan@gmail.com>
Date		: 2009-01-12 17:26 (8 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3De97a630eb0f5b8b380fd67504de6cedebb489003
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123178178029065&w=3D=
4
Handled-By	: Nick Piggin <npiggin@suse.de>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12497
Subject		: new barrier warnings in 2.6.29-rc1
Submitter	: Christoph Hellwig <hch@lst.de>
Date		: 2009-01-12 15:46 (8 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123177528217154&w=3D=
4
Handled-By	: Jens Axboe <jens.axboe@oracle.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12494
Subject		: Sony backlight regression from 2.6.28 to 29-rc
Submitter	: Norbert Preining <preining@logic.at>
Date		: 2009-01-19 8:14 (1 days old)
References	: http://marc.info/?l=3Dlinux-acpi&m=3D123235286829512&w=3D4
Handled-By	: Mattia Dongili <malattia@linux.it>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12491
Subject		: i915 lockdep warning
Submitter	: Brandeburg, Jesse <jesse.brandeburg@intel.com>
Date		: 2009-01-13 23:17 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123188898423532&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12490
Subject		: ath5k related kernel panic in 2.6.29-rc1
Submitter	: Sergey S. Kostyliov <rathamahata@gmail.com>
Date		: 2009-01-12 7:38 (8 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123174591509586&w=3D=
4
Handled-By	: Bob Copeland <me@bobcopeland.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12469
Subject		: XFS : Corruption of in-memory data
Submitter	: Haphaeu <phreytaz@gmail.com>
Date		: 2009-01-17 10:57 (3 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12468
Subject		: Crash in acpi_cpufreq_init
Submitter	: Alex Riesen <fork0@users.sf.net>
Date		: 2009-01-17 10:47 (3 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D50c668d678fd01284799a6e4f1b91829d83cb9ed


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12444
Subject		: X hangs following switch from radeonfb console - Bisected
Submitter	: Graham Murray <graham@gmurray.org.uk>
Date		: 2009-01-13 14:03 (7 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D7c1c2871a6a3a114853ec6836e9035ac1c0c7f7a


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12441
Subject		: Xorg can't use dri on radeon X1950 AGP
Submitter	: Daniel Vetter <daniel@ffwll.ch>
Date		: 2009-01-13 05:20 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12419
Subject		: possible circular locking dependency on i915 dma
Submitter	: Wang Chen <wangchen@cn.fujitsu.com>
Date		: 2009-01-08 14:11 (12 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123142399720125&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12418
Subject		: Repeated ioctl(4, 0x40046445, ..) loop in glxgears
Submitter	: Pallipadi, Venkatesh <venkatesh.pallipadi@intel.com>
Date		: 2009-01-07 22:43 (13 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D7c1c2871a6a3a114853ec6836e9035ac1c0c7f7a
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123136836213319&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12417
Subject		: glx performance drop with: "x86: PAT: implement track/untrac=
k of pfnmap regions for x86 - v3"
Submitter	: Alexey Fisher <bug-track@fisher-privat.net>
Date		: 2009-01-06 18:46 (14 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D5899329b19100c0b82dc78e9b21ed8b920c9ffb3
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123126782822696&w=3D=
4
Handled-By	: Pallipadi, Venkatesh <venkatesh.pallipadi@intel.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12416
Subject		: Recent change to kernel spikes out ccache/distcc
Submitter	: Theodore Ts'o <tytso@mit.edu>
Date		: 2009-01-06 15:15 (14 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123125495000603&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12415
Subject		: WARNING: at drivers/net/wireless/iwlwifi/iwl-sta.c:689
Submitter	: Christian Borntraeger <borntraeger@de.ibm.com>
Date		: 2009-01-05 10:36 (15 days old)
References	: http://marc.info/?l=3Dlinux-wireless&m=3D123115178019082&w=
=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12414
Subject		: iwl4965 cannot use "ap auto" on latest 2.6.28/29?
Submitter	: Jeff Chua <jeff.chua.linux@gmail.com>
Date		: 2009-01-05 4:13 (15 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123112882127823&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12402
Subject		: 2.6.29-rc: kernel BUG at fs/xfs/support/debug.c:108
Submitter	: Alexander Beregalov <a.beregalov@gmail.com>
Date		: 2009-01-09 04:41 (11 days old)
References	: http://thread.gmane.org/gmane.comp.file-systems.xfs.genera=
l/27548
Handled-By	: Christoph Hellwig <hch@infradead.org>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12509
Subject		: lockdep report. fb_mmap vs sys_mmap2
Submitter	: Dave Jones <davej@redhat.com>
Date		: 2009-01-17 18:19 (3 days old)
References	: http://lkml.org/lkml/2009/1/17/176
Handled-By	: Andrea Righi <righi.andrea@gmail.com>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D123231032115956&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12496
Subject		: swsusp cannot find resume device (sometimes)
Submitter	: Rafael J. Wysocki <rjw@sisk.pl>
Date		: 2009-01-09 12:24 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123150395731165&w=3D=
4
Handled-By	: Arjan van de Ven <arjan@infradead.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D123156441218358&w=3D4
		  http://marc.info/?t=3D123156453100002&r=3D1&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12495
Subject		: thinkpad problems during resume
Submitter	: Christian Borntraeger <borntraeger@de.ibm.com>
Date		: 2009-01-17 15:48 (3 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3De39ad415ac15116df213dfa2aa2a4f1b0857af9c
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123220746125479&w=3D=
4
		  http://marc.info/?l=3Dlinux-kernel&m=3D123170361827197&w=3D4
Handled-By	: Mike Travis <travis@sgi.com>
Patch		: http://lkml.org/lkml/2009/1/16/375
		  http://lkml.org/lkml/2009/1/16/376
		  http://lkml.org/lkml/2009/1/16/378


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12493
Subject		: ACPI related kernel panic when booting 2.6.29-rc2
Submitter	: Peter Klotz <peter.klotz@aon.at>
Date		: 2009-01-17 20:47 (3 days old)
References	: http://marc.info/?l=3Dlinux-acpi&m=3D123222565017047&w=3D4
Handled-By	: Alexey Starikovskiy <aystarik@gmail.com>
		  Tero Roponen <tero.roponen@gmail.com>
Patch		: http://marc.info/?l=3Dlinux-acpi&m=3D123223261225680&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12427
Subject		: cpumask change causes sparc build bustage
Submitter	: David Miller <davem@davemloft.net>
Date		: 2009-01-11 8:31 (9 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D588235bb53f2c215f0d4b08fd30b461fedc3338e
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123166268013838&w=3D=
4
Handled-By	: David Miller <davem@davemloft.net>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D123167571525706&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12422
Subject		: 2.6.28-git can't resume from str
Submitter	: Jeff Chua <jeff.chua.linux@gmail.com>
Date		: 2009-01-10 1:39 (10 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Da0d4922da2e4ccb0973095d8d29f36f6b1b5f703
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123155157909282&w=3D=
4
		  http://marc.info/?l=3Dlinux-kernel&m=3D123167815028388&w=3D4
Handled-By	: Rafael J. Wysocki <rjw@sisk.pl>
Patch		: http://lkml.org/lkml/2009/1/13/144


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12400
Subject		: git-latest: kernel oops in IOMMU setup
Submitter	: Dirk Hohndel <hohndel@infradead.org>
Date		: 2009-01-08 20:05 (12 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123144520124853&w=3D=
4
Handled-By	: Dirk Hohndel <hohndel@infradead.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D123152033725557&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12399
Subject		: USB wakeup problem on multiple machines
Submitter	: Rafael J. Wysocki <rjw@sisk.pl>
Date		: 2009-01-08 7:35 (12 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D6fd9086a518d4f14213a32fe6c9ac17fabebbc1e
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123140019117968&w=3D=
4
Handled-By	: Alan Stern <stern@rowland.harvard.edu>
Patch		: http://marc.info/?l=3Dlinux-usb&m=3D123186456612410&w=3D4


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.28,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D12398

Please let me know if there are any Bugzilla entries that should be add=
ed to
the list in there.

Thanks,
Rafael

--
To unsubscribe from this list: send the line "unsubscribe linux-scsi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
