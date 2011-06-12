From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 3.0-rc2: Reported regressions 2.6.38 -> 2.6.39
Date: Sun, 12 Jun 2011 23:06:41 +0200 (CEST)
Message-ID: <9NVbY1BZ_5D.A.2lE.jzS9NB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>,
	Florian Mickler <florian@mickler.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org>
Content-Disposition: inline
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/dri-devel>,
	<mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Sender: dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org
Errors-To: dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org
List-Id: netdev.vger.kernel.org

This message contains a list of some post-2.6.38 regressions introduced before
2.6.39, for which there are no fixes in the mainline known to the tracking team.
If any of them have been fixed already, please let us know.

If you know of any other unresolved post-2.6.38 regressions, please let us know
either and we'll add them to the list.  Also, please let us know if any
of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply to
this message with CCs to the people involved in reporting and handling the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2011-06-12       81       21          18
  2011-05-15       50       12          11
  2011-04-30       38       17          16
  2011-04-17       17       11          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=37132
Subject		: Random crashes on resume from hibernate on ASUS F6A
Submitter	: Dmitry Nezhevenko <dion@inhex.net>
Date		: 2011-06-10 11:00 (3 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=36962
Subject		: [Regression 2.6.39][nouveau][bisected?] leaving fullscreen XV "crashes" with KDE desktop effects enabled
Submitter	: Jan Seiffert <kaffeemonster@googlemail.com>
Date		: 2011-05-25 2:32 (19 days old)
Message-ID	: <BANLkTimd6nvXTbn2hM+cKDNKFpxzsQLHog@mail.gmail.com>
References	: http://marc.info/?l=linux-kernel&m=130629073407685&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=36952
Subject		: [2.6.39] CIFS write failures where 2.6.38 works
Submitter	: Helge Hafting <helge.hafting@hist.no>
Date		: 2011-06-01 10:11 (12 days old)
Message-ID	: <4DE6103E.6010100@hist.no>
References	: http://marc.info/?l=linux-kernel&m=130692387613423&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=36712
Subject		: 2.6.39 - crash when plugging in a usb memory stick
Submitter	: Chris Clayton <chris2553@googlemail.com>
Date		: 2011-05-27 8:09 (17 days old)
Message-ID	: <201105270909.00183.chris2553@googlemail.com>
References	: http://marc.info/?l=linux-kernel&m=130648376531197&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=36702
Subject		: 2.6.39 kernel panic w/screenshots & kernel cfg link provided
Submitter	: Justin Piszcz <jpiszcz@lucidpixels.com>
Date		: 2011-05-28 12:01 (16 days old)
Message-ID	: <alpine.DEB.2.02.1105280755050.4345@p34.internal.lan>
References	: http://marc.info/?l=linux-kernel&m=130658411008127&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=36392
Subject		: 2.6.39, 3.0-rc2 Intel DRI Regression: Black Screen after trying to play video
Submitter	: Dennis Jansen <dennis.jansen@web.de>
Date		: 2011-06-01 04:41 (12 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=36332
Subject		: Intel gpu turns external monitor off when X starts
Submitter	: rocko <rockorequin@hotmail.com>
Date		: 2011-05-31 02:53 (13 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=36182
Subject		: Erroneous package power limit notification since kernel 2.6.39
Submitter	: Olaf Freyer <aaron667@gmx.net>
Date		: 2011-05-22 13:01 (22 days old)
Message-ID	: <4DD9092A.4080507@gmx.net>
References	: http://marc.info/?l=linux-kernel&m=130606930631131&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=36092
Subject		: Filesystem lockup on USB HDD plug-in
Submitter	: Arno Wagner <arno@wagner.name>
Date		: 2011-05-28 12:34 (16 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=36012
Subject		: Kernel oops in __pskb_pull_tail
Submitter	: Steinar H. Gunderson <sgunderson@bigfoot.com>
Date		: 2011-05-27 18:21 (17 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=35922
Subject		: SND_USB_AUDIO recording device not initializing correctly
Submitter	:  <bjoern.online@gmail.com>
Date		: 2011-05-26 10:30 (18 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=35662
Subject		: softlockup with kernel 2.6.39
Submitter	: Hussam Al-Tayeb <hussam@visp.net.lb>
Date		: 2011-05-23 08:13 (21 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=35642
Subject		: On resume, I sometimes get a kernel oops with led_trigger_unregister_simple
Submitter	: Sven-Hendrik Haase <sh@lutzhaase.com>
Date		: 2011-05-23 00:15 (21 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=35242
Subject		: NULL pointer dereference in intel_sdvo_write_cmd (was Black screen after boot)
Submitter	: Ko Mi <chaostya.test@hotmail.com>
Date		: 2011-05-17 10:27 (27 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=35142
Subject		: 2.6.39-rc7-git1 boot error message (no crash)
Submitter	: werner <w.landgraf@ru.ru>
Date		: 2011-05-11 4:58 (33 days old)
Message-ID	: <web-520830057@zbackend1.aha.ru>
References	: http://marc.info/?l=linux-kernel&m=130512952706444&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=34942
Subject		: [Bug] Kdump does not work when panic triggered due to MCE
Submitter	: K.Prasad <prasad@linux.vnet.ibm.com>
Date		: 2011-05-06 16:54 (38 days old)
Message-ID	: <20110506165412.GB2719@in.ibm.com>
References	: http://marc.info/?l=linux-kernel&m=130470087226270&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=34002
Subject		: [REGRESSION] [2.6.39-rc3] Wrong resolution in framebuffer and X Window
Submitter	: Maciej Rutecki <maciej.rutecki@gmail.com>
Date		: 2011-04-17 16:04 (57 days old)
Message-ID	: <201104171804.04664.maciej.rutecki@gmail.com>
References	: http://marc.info/?l=linux-fbdev&m=130305625114863&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33842
Subject		: NULL pointer dereference in ip_fragment
Submitter	: Tomas Carnecky <tom@dbservice.com>
Date		: 2011-04-23 07:51 (51 days old)


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=35572
Subject		: eeprom module: modprobing hangs
Submitter	: Mark <markotahal@gmail.com>
Date		: 2011-05-21 20:17 (23 days old)
Handled-By	: Jean Delvare <khali@linux-fr.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=60812


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=34662
Subject		: Warning at block/genhd.c:1556 disk_clear_events
Submitter	: Meelis Roos <mroos@linux.ee>
Date		: 2011-05-02 9:59 (42 days old)
Message-ID	: <alpine.SOC.1.00.1105021255400.6200@math.ut.ee>
References	: http://marc.info/?l=linux-kernel&m=130433037002610&w=2
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=58262


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33242
Subject		: Lockdep splat in autofs with 2.6.39-rc2
Submitter	: Nick Bowler <nbowler@elliptictech.com>
Date		: 2011-04-07 19:44 (67 days old)
Message-ID	: <20110407194403.GA29404@elliptictech.com>
References	: http://marc.info/?l=linux-kernel&m=130220545614682&w=2
Patch		: http://marc.info/?l=linux-kernel&m=130342115008659&w=2


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions introduced
between 2.6.38 and 2.6.39, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=32012

Please let the tracking team know if there are any Bugzilla entries that
should be added to the list in there.

Thanks!
