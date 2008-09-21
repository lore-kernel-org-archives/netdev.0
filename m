From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.27-rc6-git6: Reported regressions from 2.6.26
Date: Sun, 21 Sep 2008 20:52:14 +0200 (CEST)
Message-ID: <PJz8fNrJNHG.A.65F.wzq1IB@albercik>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
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
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions from 2.6.26, for which there
are no fixes in the mainline I know of.  If any of them have been fixed already,
please let me know.

If you know of any other unresolved regressions from 2.6.26, please let me know
either and I'll add them to the list.  Also, please let me know if any of the
entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply to
this message with CCs to the people involved in reporting and handling the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2008-09-21      169       45          36


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11611
Subject		: Commit 2344abbcbdb82140050e8be29d3d55e4f6fe860b breaks resume on nx6325
Submitter	: Rafael J. Wysocki <rjw@sisk.pl>
Date		: 2008-09-20 23:24 (2 days old)
References	: http://marc.info/?l=linux-kernel&m=122195277606974&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11610
Subject		: Problem with kernel commit 664d080c41463570b95717b5ad86e79dc1be0877
Submitter	: Michal 'vorner' Vaner <vorner@ucw.cz>
Date		: 2008-09-21 17:35 (1 days old)
References	: http://marc.info/?l=linux-acpi&m=122201853409501&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11609
Subject		: oops in find_get_page
Submitter	: Marcin Slusarz <marcin.slusarz@gmail.com>
Date		: 2008-09-20 14:53 (2 days old)
References	: http://marc.info/?l=linux-kernel&m=122192251101892&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11608
Subject		: 2.6.27-rc6 BUG: unable to handle kernel paging request
Submitter	: John Daiker <daikerjohn@gmail.com>
Date		: 2008-09-16 23:00 (6 days old)
References	: http://marc.info/?l=linux-kernel&m=122160611517267&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11607
Subject		: 2.6.27-rc6 =C2=A0Bug in tty_chars_in_buffer
Submitter	: John Daiker <daikerjohn@gmail.com>
Date		: 2008-09-15 2:26 (7 days old)
References	: http://marc.info/?l=linux-kernel&m=122144565514490&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11590
Subject		: Nokia 5310 Xpress usb-storage not mounting
Submitter	: David Almaroad <dalmaroad@gmail.com>
Date		: 2008-09-18 21:35 (4 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11569
Subject		: Don't complain about disabled irqs when the system has paniced
Submitter	: Andi Kleen <andi@firstfloor.org>
Date		: 2008-09-02 13:49 (20 days old)
References	: http://marc.info/?l=linux-kernel&m=122036356127282&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11568
Subject		: spontaneous reboot on resume with 2.6.27
Submitter	: Andy Wettstein <ajw1980@gmail.com>
Date		: 2008-09-14 20:00 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11551
Subject		: Semi-repeatable hard lockup on 2.6.27-rc6
Submitter	: Steven Noonan <steven@uplinklabs.net>
Date		: 2008-09-10 18:07 (12 days old)
References	: http://marc.info/?l=linux-kernel&m=122107007407994&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11548
Subject		: kernel BUG at drivers/pci/intel-iommu.c:1373!
Submitter	: Chris Mason <chris.mason@oracle.com>
Date		: 2008-09-08 14:26 (14 days old)
References	: http://marc.info/?l=linux-kernel&m=122088566310440&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11543
Subject		: kernel panic: softlockup in tick_periodic() ???
Submitter	: Joshua Hoblitt <j_kernel@hoblitt.com>
Date		: 2008-09-11 16:46 (11 days old)
References	: http://marc.info/?l=linux-kernel&m=122117786124326&w=4
Handled-By	: Thomas Gleixner <tglx@linutronix.de>
		  Cyrill Gorcunov <gorcunov@gmail.com>
		  Ingo Molnar <mingo@elte.hu>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11516
Subject		: severe performance degradation on x86_64 going from 2.6.26-rc9 -&gt; 2.6.27= -rc5
Submitter	: Jason Vas Dias <jason.vas.dias@gmail.com>
Date		: 2008-09-07 13:59 (15 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11512
Subject		: sort-of regression due to "kconfig: speed up all*config + randconfig"
Submitter	: Alexey Dobriyan <adobriyan@gmail.com>
Date		: 2008-09-05 22:50 (17 days old)
References	: http://marc.info/?l=linux-kernel&m=122065498013858&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11506
Subject		: oops during unmount - ext3? (2.6.27-rc5)
Submitter	: Marcin Slusarz <marcin.slusarz@gmail.com>
Date		: 2008-09-04 19:14 (18 days old)
References	: http://marc.info/?l=linux-kernel&m=122055573123449&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11504
Subject		: reiserfs =C2=A0BUG in 2.6.27-rc5
Submitter	: Randy Dunlap <randy.dunlap@oracle.com>
Date		: 2008-09-03 16:35 (19 days old)
References	: http://marc.info/?l=linux-kernel&m=122045982120138&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11501
Subject		: Failed to open destination file: Permission deniedihex2fw
Submitter	: Andrew Morton <akpm@linux-foundation.org>
Date		: 2008-09-04 18:34 (18 days old)
References	: http://marc.info/?l=linux-kernel&m=122055342419068&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11476
Subject		: failure to associate after resume from suspend to ram
Submitter	: Michael S. Tsirkin <m.s.tsirkin@gmail.com>
Date		: 2008-09-01 13:33 (21 days old)
References	: http://marc.info/?l=linux-kernel&m=122028529415108&w=4
Handled-By	: Zhu Yi <yi.zhu@intel.com>
		  Dan Williams <dcbw@redhat.com>
		  Jouni Malinen <j@w1.fi>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11465
Subject		: Linux-2.6.27-rc5, drm errors in log
Submitter	: Gene Heskett <gene.heskett@verizon.net>
Date		: 2008-08-30 18:52 (23 days old)
References	: http://marc.info/?l=linux-kernel&m=122012238925775&w=4
Handled-By	: Dave Airlie <airlied@gmail.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11459
Subject		: kernel crash after wifi connection established
Submitter	: Alexey Kuznetsov <ak@axet.ru>
Date		: 2008-08-30 03:08 (23 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11407
Subject		: suspend: unable to handle kernel paging request
Submitter	: Vegard Nossum <vegard.nossum@gmail.com>
Date		: 2008-08-21 17:28 (32 days old)
References	: http://marc.info/?l=linux-kernel&m=121933974928881&w=4
Handled-By	: Rafael J. Wysocki <rjw@sisk.pl>
		  Pekka Enberg <penberg@cs.helsinki.fi>
		  Pavel Machek <pavel@suse.cz>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11404
Subject		: BUG: in 2.6.23-rc3-git7 in do_cciss_intr
Submitter	: rdunlap <randy.dunlap@oracle.com>
Date		: 2008-08-21 5:52 (32 days old)
References	: http://marc.info/?l=linux-kernel&m=121929819616273&w=4
		  http://marc.info/?l=linux-kernel&m=121932889105368&w=4
Handled-By	: Miller, Mike (OS Dev) <Mike.Miller@hp.com>
		  James Bottomley <James.Bottomley@hansenpartnership.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11382
Subject		: e1000e: 2.6.27-rc1 corrupts EEPROM/NVM
Submitter	: David Vrabel <david.vrabel@csr.com>
Date		: 2008-08-08 10:47 (45 days old)
References	: http://marc.info/?l=linux-kernel&m=121819267211679&w=4
Handled-By	: Christopher Li <chrisl@vmware.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11380
Subject		: lockdep warning: cpu_add_remove_lock at:cpu_maps_update_begin+0x14/0x16
Submitter	: Ingo Molnar <mingo@elte.hu>
Date		: 2008-08-20 6:44 (33 days old)
References	: http://marc.info/?l=linux-kernel&m=121921480931970&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11357
Subject		: Can not boot up with zd1211rw USB-Wlan Stick
Submitter	: uwe <kender@freenet.de>
Date		: 2008-08-16 14:17 (37 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11340
Subject		: LTP overnight run resulted in unusable box
Submitter	: Alexey Dobriyan <adobriyan@gmail.com>
Date		: 2008-08-13 9:24 (40 days old)
References	: http://marc.info/?l=linux-kernel&m=121861951902949&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11335
Subject		: 2.6.27-rc2-git5 BUG: unable to handle kernel paging request
Submitter	: Randy Dunlap <randy.dunlap@oracle.com>
Date		: 2008-08-12 4:18 (41 days old)
References	: http://marc.info/?l=linux-kernel&m=121851477201960&w=4
		  http://lkml.org/lkml/2008/8/16/274
Handled-By	: Hugh Dickins <hugh@veritas.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11308
Subject		: tbench regression on each kernel release from 2.6.22 -&gt; 2.6.28
Submitter	: Christoph Lameter <cl@linux-foundation.org>
Date		: 2008-08-11 18:36 (42 days old)
References	: http://marc.info/?l=linux-kernel&m=121847986119495&w=4
		  http://marc.info/?l=linux-kernel&m=122125737421332&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11272
Subject		: BUG: parport_serial in 2.6.27-rc1 for NetMos Technology PCI 9835
Submitter	: Jaswinder Singh <jaswinderlinux@gmail.com>
Date		: 2008-08-05 15:12 (48 days old)
References	: http://marc.info/?l=linux-kernel&m=121794900319776&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11271
Subject		: BUG: fealnx in 2.6.27-rc1
Submitter	: Jaswinder Singh <jaswinderlinux@gmail.com>
Date		: 2008-08-05 14:58 (48 days old)
References	: http://marc.info/?l=linux-netdev&m=121794762016830&w=4
		  http://lkml.org/lkml/2008/8/10/98
Handled-By	: Francois Romieu <romieu@fr.zoreil.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11264
Subject		: Invalid op opcode in kernel/workqueue
Submitter	: Jean-Luc Coulon <jean.luc.coulon@gmail.com>
Date		: 2008-08-07 04:18 (46 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11230
Subject		: Kconfig no longer outputs a .config with freshly updated defconfigs
Submitter	: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Date		: 2008-08-02 16:03 (51 days old)
References	: http://marc.info/?l=linux-kernel&m=121769306319391&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11224
Subject		: Only three cores found on quad-core machine.
Submitter	: Dave Jones <davej@redhat.com>
Date		: 2008-08-01 18:15 (52 days old)
References	: http://marc.info/?l=linux-kernel&m=121761475224719&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11220
Subject		: Screen stays black after resume
Submitter	: Nico Schottelius <nico@schottelius.org>
Date		: 2008-07-31 21:05 (53 days old)
References	: http://marc.info/?l=linux-kernel&m=121753882422899&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11215
Subject		: INFO: possible recursive locking detected ps2_command
Submitter	: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date		: 2008-07-31 9:41 (53 days old)
References	: http://marc.info/?l=linux-kernel&m=121749737011637&w=4
Handled-By	: Peter Zijlstra <a.p.zijlstra@chello.nl>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11210
Subject		: libata badness
Submitter	: Kumar Gala <galak@kernel.crashing.org>
Date		: 2008-07-31 18:53 (53 days old)
References	: http://marc.info/?l=linux-ide&m=121753059307310&w=4
Handled-By	: Kumar Gala <galak@kernel.crashing.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11207
Subject		: VolanoMark regression with 2.6.27-rc1
Submitter	: Zhang, Yanmin <yanmin_zhang@linux.intel.com>
Date		: 2008-07-31 3:20 (53 days old)
References	: http://marc.info/?l=linux-kernel&m=121747464114335&w=4
Handled-By	: Zhang, Yanmin <yanmin_zhang@linux.intel.com>
		  Peter Zijlstra <a.p.zijlstra@chello.nl>
		  Dhaval Giani <dhaval@linux.vnet.ibm.com>
		  Miao Xie <miaox@cn.fujitsu.com>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11555
Subject		: rmmod ide-cd_mod: tried to init an initialized =C2=A0object, something is s= eriously wrong.
Submitter	: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Date		: 2008-07-16 2:22 (68 days old)
References	: http://marc.info/?l=linux-ide&m=122061839713526&w=4
Handled-By	: Jens Axboe <jens.axboe@oracle.com>
Patch		: http://marc.info/?l=linux-kernel&m=122095622602315&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11552
Subject		: Disabling IRQ #23
Submitter	: Justin Mattock <justinmattock@gmail.com>
Date		: 2008-09-09 19:08 (13 days old)
References	: http://marc.info/?l=linux-kernel&m=122098735230906&w=4
		  http://marc.info/?l=linux-kernel&m=122107367715361&w=4
Handled-By	: David Brownell <david-b@pacbell.net>
		  Alan Stern <stern@rowland.harvard.edu>
Patch		: http://marc.info/?l=linux-kernel&m=122187222705195&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11550
Subject		: pnp: Huge number of "io resource overlap" messages
Submitter	: Frans Pop <elendil@planet.nl>
Date		: 2008-09-09 10:50 (13 days old)
References	: http://marc.info/?l=linux-kernel&m=122095745403793&w=4
Handled-By	: Rene Herman <rene.herman@keyaccess.nl>
		  Bjorn Helgaas <bjorn.helgaas@hp.com>
Patch		: http://marc.info/?l=linux-kernel&m=122098498125536&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11549
Subject		: 2.6.27-rc5 acpi: EC Storm error message on bootup
Submitter	: <jmerkey@wolfmountaingroup.com>
Date		: 2008-09-02 21:27 (20 days old)
References	: http://marc.info/?l=linux-kernel&m=122039255517586&w=4
Handled-By	: Alexey Starikovskiy <astarikovskiy@suse.de>
Patch		: http://marc.info/?l=linux-kernel&m=122098180019264&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11507
Subject		: usb: sometimes dead keyboard after boot
Submitter	: Frans Pop <elendil@planet.nl>
Date		: 2008-08-26 21:03 (27 days old)
References	: http://marc.info/?l=linux-kernel&m=121977815018224&w=2
Handled-By	: Alan Stern <stern@rowland.harvard.edu>
Patch		: http://www.spinics.net/lists/linux-usb/msg09735.html


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11505
Subject		: oltp ~10% regression with 2.6.27-rc5 on stoakley machine
Submitter	: Lin Ming <ming.m.lin@intel.com>
Date		: 2008-09-04 7:06 (18 days old)
References	: http://marc.info/?l=linux-kernel&m=122051202202373&w=4
		  http://marc.info/?t=122089704700005&r=1&w=4
Handled-By	: Peter Zijlstra <a.p.zijlstra@chello.nl>
		  Gregory Haskins <ghaskins@novell.com>
		  Ingo Molnar <mingo@elte.hu>
Patch		: http://marc.info/?l=linux-kernel&m=122194673932703&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11442
Subject		: btusb hibernation/suspend breakage in current -git
Submitter	: Rafael J. Wysocki <rjw@sisk.pl>
Date		: 2008-08-25 11:37 (28 days old)
References	: http://marc.info/?l=linux-bluetooth&m=121966402012074&w=4
Handled-By	: Oliver Neukum <oliver@neukum.org>
Patch		: http://marc.info/?l=linux-bluetooth&m=121967226027323&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11439
Subject		: [2.6.27-rc4-git4] compilation warnings
Submitter	: Rufus &amp; Azrael <rufus-azrael@numericable.fr>
Date		: 2008-08-26 9:37 (27 days old)
References	: http://marc.info/?l=linux-kernel&m=121974353815440&w=4
Handled-By	: Greg KH <gregkh@suse.de>
Patch		: http://marc.info/?l=linux-kernel&m=121976424221858&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11237
Subject		: corrupt PMD after resume
Submitter	: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
Date		: 2008-08-02 9:51 (51 days old)
References	: http://marc.info/?l=linux-kernel&m=121767073424952&w=4
Handled-By	: Hugh Dickins <hugh@veritas.com>
		  Jeremy Fitzhardinge <jeremy@goop.org>
Patch		: http://marc.info/?l=linux-kernel&m=122001615314700&w=2


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions from 2.6.26,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=11167

Please let me know if there are any Bugzilla entries that should be added to
the list in there.

Thanks,
Rafael

