From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.34-rc6-git2: Reported regressions from 2.6.33
Date: Tue,  4 May 2010 22:49:09 +0200 (CEST)
Message-ID: <JzEGxUyyQHG.A.ZtH.YHJ4LB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej Rutecki <maciej.rutecki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
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

This message contains a list of some regressions from 2.6.33,
for which there are no fixes in the mainline known to the tracking team=
=2E
If any of them have been fixed already, please let us know.

If you know of any other unresolved regressions from 2.6.33, please let=
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
  2010-05-04       76       26          22
  2010-04-20       64       35          34
  2010-04-07       48       35          33
  2010-03-21       15       13          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15880
Subject		: Very bad regression from 2.6.33 as of 1600f9def
Submitter	: Alex Elsayed <eternaleye@gmail.com>
Date		: 2010-04-29 2:28 (6 days old)
Message-ID	: <loom.20100429T041908-663@post.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127250825306178&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15863
Subject		: 2.6.34-rc5-git7 (plus all patches) -- another suspicious rcu=
_dereference_check() usage.
Submitter	: Miles Lane <miles.lane@gmail.com>
Date		: 2010-04-27 0:51 (8 days old)
Message-ID	: <h2ya44ae5cd1004261751waa5cb65ei3d139cbcfa2cc5cf@mail.gmai=
l.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127232949104878&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15862
Subject		: 2.6.34-rc4/5: iwlagn unusable until reload
Submitter	: Nico Schottelius <nico-linux-20100427@schottelius.org>
Date		: 2010-04-27 7:49 (8 days old)
Message-ID	: <20100427074934.GB3261@ikn.schottelius.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127235784004839&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15858
Subject		: [2.6.34-rc5] bad page state copying to/from HFS+ filesystem.=
=2E.
Submitter	: Daniel J Blueman <daniel.blueman@gmail.com>
Date		: 2010-04-25 21:14 (10 days old)
Message-ID	: <v2k6278d2221004251414kbbcc41baw78b86120d81dce7d@mail.gmai=
l.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127223008621881&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15805
Subject		: reiserfs locking
Submitter	: Alexander Beregalov <a.beregalov@gmail.com>
Date		: 2010-04-15 21:02 (20 days old)
Message-ID	: <t2ka4423d671004151402n7b2dc425mdc9c6bb9640d63fb@mail.gmai=
l.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127136535323933&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15790
Subject		: Meta-Bug: Regressions
Submitter	: Florian Mickler <fmickler@gmx.de>
Date		: 2010-04-15 18:21 (20 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15788
Subject		: external usb sound card doesn't work after resume
Submitter	: Fran=C3=A7ois Valenduc <francois.valenduc@tvcablenet.be>
Date		: 2010-04-15 10:16 (20 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15717
Subject		: bluetooth oops
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2010-03-14 20:14 (52 days old)
Message-ID	: <20100314201434.GE22059@elf.ucw.cz>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126859771528426&w=3D=
4
Handled-By	: Marcel Holtmann <marcel@holtmann.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15713
Subject		: hackbench regression due to commit 9dfc6e68bfe6e
Submitter	: Alex Shi <alex.shi@intel.com>
Date		: 2010-03-25 8:40 (41 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/9dfc6e68bfe6ee452efb1a4=
e9ca26a9007f2b864
Message-ID	: <1269506457.4513.141.camel@alexs-hp.sh.intel.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126950632920682&w=3D=
4
Handled-By	: Christoph Lameter <cl@linux-foundation.org>
		  Pekka Enberg <penberg@cs.helsinki.fi>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15712
Subject		: [regression] 2.6.34-rc1 to -rc3 on zaurus: no longer boots
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2010-04-01 6:06 (34 days old)
Message-ID	: <20100401060624.GA1329@ucw.cz>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127010200817402&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15704
Subject		: [r8169] WARNING: at net/sched/sch_generic.c
Submitter	: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date		: 2010-03-31 10:21 (35 days old)
Message-ID	: <<20100331102142.GA3294@swordfish.minsk.epam.com>>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127003090406108&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15673
Subject		: 2.6.34-rc2: "ima_dec_counts: open/free imbalance"?
Submitter	: Thomas Meyer <thomas@m3y3r.de>
Date		: 2010-03-28 11:31 (38 days old)
Message-ID	: <1269775909.5301.4.camel@localhost.localdomain>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126977593326800&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15671
Subject		: intel graphic card hanging (Hangcheck timer elapsed... GPU h=
ung)
Submitter	: Norbert Preining <preining@logic.at>
Date		: 2010-03-27 16:11 (39 days old)
Message-ID	: <20100327161104.GA12043@gamma.logic.tuwien.ac.at>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126970883105262&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15669
Subject		: INFO: suspicious rcu_dereference_check()
Submitter	: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date		: 2010-03-08 1:26 (58 days old)
Message-ID	: <c4e36d111003250348q678eb2e6w4f3e8133e7fd6e58@mail.gmail.c=
om>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126801163107713&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15664
Subject		: Graphics hang and kernel backtrace when starting Azureus wit=
h Compiz enabled
Submitter	: Alex Villacis Lasso <avillaci@ceibo.fiec.espol.edu.ec>
Date		: 2010-04-01 01:09 (34 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15659
Subject		: [Regresion] [2.6.34-rc1] [drm:i915_hangcheck_elapsed] *ERROR=
* Hangcheck timer elapsed... GPU hung
Submitter	: Maciej Rutecki <maciej.rutecki@gmail.com>
Date		: 2010-03-25 20:04 (41 days old)
Message-ID	: <<201003252104.24965.maciej.rutecki@gmail.com>>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126954749618319&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15625
Subject		: BUG: 2.6.34-rc1, RIP is (null)
Submitter	: Randy Dunlap <randy.dunlap@oracle.com>
Date		: 2010-03-18 22:22 (48 days old)
Message-ID	: <4BA2A7A9.4080503@oracle.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126895098217351&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15611
Subject		: Failure with the 2.6.34-rc1 kernel
Submitter	: Rupjyoti Sarmah <rsarmah@amcc.com>
Date		: 2010-03-16 15:45 (50 days old)
Message-ID	: <AC311A8E81420D4EBC1F26E6479848FE065B7D3D@SDCEXCHANGE01.ad=
=2Eamcc.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126875435718396&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15610
Subject		: fsck leads to swapper - BUG: unable to handle kernel NULL po=
inter dereference & panic
Submitter	: Ozgur Yuksel <ozgur.yuksel@oracle.com>
Date		: 2010-03-22 15:59 (44 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15601
Subject		: [BUG] SLOB breaks Crypto
Submitter	: michael-dev@fami-braun.de
Date		: 2010-03-15 13:39 (51 days old)
Message-ID	: <4B9E38AF.70309@fami-braun.de>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126866044724539&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15590
Subject		: 2.6.34-rc1: regression: ^Z no longer stops sound
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2010-03-14 7:58 (52 days old)
Message-ID	: <20100314075831.GA13457@elf.ucw.cz>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126855353122623&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15589
Subject		: 2.6.34-rc1: Badness at fs/proc/generic.c:316
Submitter	: Christian Kujau <lists@nerdbynature.de>
Date		: 2010-03-13 23:53 (53 days old)
Message-ID	: <alpine.DEB.2.01.1003131544340.5493@bogon.housecafe.de>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126852442903680&w=3D=
2


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15893
Subject		: Alps: No edge-scrolling since 2.6.34-rc5
Submitter	: Felix Zweig <f.zweig@yahoo.de>
Date		: 2010-05-01 16:23 (4 days old)
Handled-By	:  Dan Carpenter <error27@gmail.com>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=3D26218


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15768
Subject		: Incorrectly calculated free blocks result in ENOSPC from wri=
tepage
Submitter	: Dmitry Monakhov <dmonakhov@openvz.org>
Date		: 2010-04-12 11:24 (23 days old)
Handled-By	: Dmitry Monakhov <dmonakhov@openvz.org>
Patch		: http://patchwork.ozlabs.org/patch/49989/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15729
Subject		: BUG: physmap modprobe & rmmod
Submitter	: Randy Dunlap <randy.dunlap@oracle.com>
Date		: 2010-04-02 20:40 (33 days old)
Message-ID	: <20100402134058.c4682716.randy.dunlap@oracle.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127024096210230&w=3D=
2
Handled-By	: Hartley Sweeten <hsweeten@visionengravers.com>
Patch		: https://patchwork.kernel.org/patch/90497/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15505
Subject		: No more b43 wireless interface since 2.6.34-rc1
Submitter	: Christian Casteyde <casteyde.christian@free.fr>
Date		: 2010-03-10 06:59 (56 days old)
Handled-By	: Yinghai Lu <yinghai@kernel.org>
Patch		: https://bugzilla.kernel.org/show_bug.cgi?id=3D15505#c11


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.33,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D15310

Please let the tracking team know if there are any Bugzilla entries tha=
t
should be added to the list in there.

Thanks!

--
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
