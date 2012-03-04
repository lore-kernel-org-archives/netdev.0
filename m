From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 3.3-rc6: Reported regressions from 3.2
Date: Sun,  4 Mar 2012 21:29:30 +0100 (CET)
Message-ID: <FNlNbnGKWLP.A.dME.3F9UPB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej Rutecki <maciej.rutecki@gmail.com>,
	Florian Mickler <florian@mickler.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:54469 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754888Ab2CDUti convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 15:49:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

It looks like many people have switched away from the kernel Bugzilla
after the kernel.org outage and they are using various means of reporti=
ng
(and tracking) kernel bugs.  For this reason, it's becoming increasingl=
y
difficult for us to track all of the possible sources of reports and we
are not aware of a number of them as a result.  To tackle this issue we
kindly request that regression reports be CCed or forwarded to the LKML
as stated below.

Thanks,
Rafael

-----------------------------------------------------------------------=
------

This message contains a list of some regressions from 3.2,
for which there are no fixes in the mainline known to the tracking team=
=2E
If any of them have been fixed already, please let us know.

If you know of any other unresolved regressions from 3.2, please let us
know either and we'll add them to the list.  Moreover, when you are
reporting a kernel regression, please send a CC of your report to the L=
KML
(or forward it to the LKML if you are not reporting the regression by e=
-mail)
with the word "regression" in the subject, as that will make it much
easier for us to find it.  Also, please let us know if any of the entri=
es
below are invalid.

Each entry from the list will be sent additionally in an automatic repl=
y
to this message with CCs to the people involved in reporting and handli=
ng
the issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2012-03-04       23       15          15
  2012-02-23       15       13          13


Unresolved regressions
----------------------

Bug-Entry	: https://bugzilla.kernel.org/show_bug.cgi?id=3D42860
Subject		: 3.3.0-rc5: OOps in dql_completed (Broadcom tg3 driver)
Submitter	: Christoph Lameter <cl@gentwo.org>
Date		: 2012-03-01 21:13 (4 days old)
Message-ID	: <alpine.DEB.2.00.1203011505510.6685@router.home>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D133063645224373&w=3D=
2


Bug-Entry	: https://bugzilla.kernel.org/show_bug.cgi?id=3D42850
Subject		: [BUG] Kernel Bug at fs/btrfs/volumes.c:3638
Submitter	: Nageswara R Sastry <rnsastry@linux.vnet.ibm.com>
Date		: 2012-02-24 10:53 (10 days old)
Message-ID	: <4F476959.2010400@linux.vnet.ibm.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D133008013332251&w=3D=
2


Bug-Entry	: https://bugzilla.kernel.org/show_bug.cgi?id=3D42823
Subject		: WARNING: at block/genhd.c:1465
Submitter	: Christian Kujau <lists@nerdbynature.de>
Date		: 2012-02-21 11:00 (13 days old)
Message-ID	: <alpine.DEB.2.01.1202210246400.4930@trent.utfs.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132982259213941&w=3D=
2


Bug-Entry	: https://bugzilla.kernel.org/show_bug.cgi?id=3D42822
Subject		: [3.3.0-rc3][uvcvideo][regression] oops - uvc_video_clock_upd=
ate
Submitter	: Shawn Starr <shawn.starr@rogers.com>
Date		: 2012-02-20 1:08 (14 days old)
Message-ID	: <5887142.ZMTDAjc4qf@segfault.sh0n.net>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132970057611642&w=3D=
2


Bug-Entry	: https://bugzilla.kernel.org/show_bug.cgi?id=3D42821
Subject		: alpha: futex regression bisected
Submitter	: Michael Cree <mcree@orcon.net.nz>
Date		: 2012-02-20 8:20 (14 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/8d7718aa082aaf30a0b4989=
e1f04858952f941bc
Message-ID	: <4F420256.2090600@orcon.net.nz>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132972606917069&w=3D=
2


Bug-Entry	: https://bugzilla.kernel.org/show_bug.cgi?id=3D42776
Subject		: OF-related boot crash in 3.3.0-rc3-00188-g3ec1e88
Submitter	: Meelis Roos <mroos@linux.ee>
Date		: 2012-02-13 7:45 (21 days old)
Message-ID	: <alpine.SOC.1.00.1202130942030.1488@math.ut.ee>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132911916331615&w=3D=
2
		  http://marc.info/?l=3Dlinux-kernel&m=3D132993294018762&w=3D2


Bug-Entry	: https://bugzilla.kernel.org/show_bug.cgi?id=3D42761
Subject		: Possible circular locking dependency (3.3-rc2)
Submitter	: Felipe Balbi <balbi@ti.com>
Date		: 2012-02-08 12:41 (26 days old)
Message-ID	: <20120208124147.GF16334@legolas.emea.dhcp.ti.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132870492311858&w=3D=
2


Bug-Entry	: https://bugzilla.kernel.org/show_bug.cgi?id=3D42746
Subject		: 3.3-rc2 snd_pcm lockdep backtrace
Submitter	: Josh Boyer <jwboyer@redhat.com>
Date		: 2012-02-06 14:56 (28 days old)
Message-ID	: <20120206145621.GA4771@zod.bos.redhat.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132854040916172&w=3D=
2


Bug-Entry	: https://bugzilla.kernel.org/show_bug.cgi?id=3D42733
Subject		: Regression 3.2 -> 3.3-rc1 10 sec hang at boot and resume, CO=
MRESET failed
Submitter	: Norbert Preining <preining@logic.at>
Date		: 2012-02-02 5:12 (32 days old)
Message-ID	: <20120202051258.GA15550@gamma.logic.tuwien.ac.at>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132815978615112&w=3D=
2


Bug-Entry	: https://bugzilla.kernel.org/show_bug.cgi?id=3D42713
Subject		: Regression in skge that started around acb42a3 (so past v3.3=
-rc1)
Submitter	: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date		: 2012-01-30 15:58 (35 days old)
Message-ID	: <20120130155816.GA1400@phenom.dumpdata.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132793944220262&w=3D=
2


Bug-Entry	: https://bugzilla.kernel.org/show_bug.cgi?id=3D42707
Subject		: Hang deconfiguring network interface (in shutdown) on 3.3-rc=
1
Submitter	: James Bottomley <James.Bottomley@hansenpartnership.com>
Date		: 2012-01-28 19:56 (37 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/92feeabf3f673767c6ee4cf=
c7fc224098446c1c1
Message-ID	: <1327780565.2924.24.camel@dabdike.int.hansenpartnership.co=
m>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132778076214873&w=3D=
2


Bug-Entry	: https://bugzilla.kernel.org/show_bug.cgi?id=3D42686
Subject		: iwlagn is getting even worse with 3.3-rc1
Submitter	: Norbert Preining <preining@logic.at>
Date		: 2012-01-24 1:36 (41 days old)
Message-ID	: <20120124013625.GB18436@gamma.logic.tuwien.ac.at>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132736918325378&w=3D=
2


Bug-Entry	: https://bugzilla.kernel.org/show_bug.cgi?id=3D42683
Subject		: WARN... Device 'cpu1' does not have a release() function, it=
 is broken and must be fixed. when doing 'xl vcpu-set <guest_id> 1'
Submitter	: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date		: 2012-01-23 18:06 (42 days old)
Message-ID	: <20120123180601.GA24553@phenom.dumpdata.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132734233916154&w=3D=
2


Bug-Entry	: https://bugzilla.kernel.org/show_bug.cgi?id=3D42678
Subject		: [3.3-rc1] radeon stuck in kernel after lockup
Submitter	: Torsten Kaiser <just.for.lkml@googlemail.com>
Date		: 2012-01-21 19:03 (44 days old)
Message-ID	: <CAPVoSvSXMvRb=3D1itu9DjF+s=3D6zfAChvUxS-x=3Db8EV9kOZinNpA=
@mail.gmail.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132717279606670&w=3D=
2
Handled-By	: J=C3=A9r=C3=B4me Glisse <glisse@freedesktop.org>


Bug-Entry	: https://bugzilla.kernel.org/show_bug.cgi?id=3D42649
Subject		: Regression 3.2 -> 3.3-rc1 commit b4b583d4 inet/media keyboar=
d: stuck "extra" keys
Submitter	: Duncan <1i5t5.duncan@cox.net>
Date		: 2012-01-24 18:18 (41 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/b4b583d4e9a5ff28c4a150b=
b25a4fff5cd4dfbbd


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 3=
=2E2,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D42644

Please let the tracking team know if there are any Bugzilla entries tha=
t
should be added to the list in there.

Thanks!
