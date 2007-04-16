From: Adrian Bunk <bunk@stusta.de>
Subject: [1/2] 2.6.21-rc7: known regressions
Date: Mon, 16 Apr 2007 02:37:14 +0200
Message-ID: <20070416003714.GL3691@stusta.de>
References: <Pine.LNX.4.64.0704151659570.5473@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Hans-Georg Rist <hg.rist@web.de>, perex@suse.cz,
	alsa-devel@alsa-project.org,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Stephen Clark <Stephen.Clark@seclark.us>, jgarzik@pobox.com,
	linux-ide@vger.kernel.org,
	Michal Jaegermann <michal@ellpspace.math.ualberta.ca>,
	lenb@kernel.org, linux-acpi@vger.kernel.org,
	netdev@vger.kernel.org, Dave Jones <davej@redhat.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net, Ingo Molnar <mingo@elte.hu>,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	David Miller <davem@davemloft.net>, Andi Kleen <ak@suse.de>,
	Oliver Neukum <oneukum@suse.de>, greg@kroah.com,
	linux-usb-devel@lists.sourceforge.net, CIJOML <cijoml@volny.cz>,
	Markus Rechberger <markus.rechberger@amd.com>,
	v4l-dvb-maintainer@linuxtv.org
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704151659570.5473@woody.linux-foundation.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This email lists some known regressions in Linus' tree compared to 2.6.20.

If you find your name in the Cc header, you are either submitter of one
of the bugs, maintainer of an affectected subsystem or driver, a patch
of you caused a breakage or I'm considering you in any other way
possibly involved with one or more of these issues.

Due to the huge amount of recipients, please trim the Cc when answering.


Subject    : snd_hda_intel doesn't work with ASUS M2V mainboard
References : http://bugzilla.kernel.org/show_bug.cgi?id=8273
Submitter  : Hans-Georg Rist <hg.rist@web.de>
Status     : unknown


Subject    : snd_intel8x0: divide error: 0000
References : http://lkml.org/lkml/2007/3/5/252
Submitter  : Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Status     : unknown


Subject    : ali_pata: boot from CD fails
References : http://lkml.org/lkml/2007/3/31/160
Submitter  : Stephen Clark <Stephen.Clark@seclark.us>
Status     : unknown


Subject    : kernels fail to boot with drives on ATIIXP controller
             (ACPI/IRQ related)
References : https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=229621
             http://lkml.org/lkml/2007/3/4/257
Submitter  : Michal Jaegermann <michal@ellpspace.math.ualberta.ca>
Status     : unknown


Subject    : boot failure: rtl8139: exception in interrupt routine
References : http://lkml.org/lkml/2007/3/31/160
Submitter  : Stephen Clark <Stephen.Clark@seclark.us>
Status     : unknown


Subject    : laptops with e1000: lockups
References : https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=229603
Submitter  : Dave Jones <davej@redhat.com>
Handled-By : Jesse Brandeburg <jesse.brandeburg@intel.com>
Status     : problem is being debugged


Subject    : forcedeth: interface hangs under load
References : http://lkml.org/lkml/2007/4/3/39
             http://www.spinics.net/lists/netdev/msg28981.html
Submitter  : Ingo Molnar <mingo@elte.hu>
Handled-By : Ingo Molnar <mingo@elte.hu>
             Ayaz Abdulla <aabdulla@nvidia.com>
             David Miller <davem@davemloft.net>
Status     : problem is being debugged


Subject    : hal daemon crashes after pulling a USB serial device
References : http://www.opensubscriber.com/message/linux-usb-devel@lists.sourceforge.net/6369800.html
Submitter  : Andi Kleen <ak@suse.de>
Handled-By : Oliver Neukum <oneukum@suse.de>
Status     : problem is being debugged


Subject    : Oops when changing USB DVB-T adapter
References : http://lkml.org/lkml/2007/3/9/212
             http://lkml.org/lkml/2007/4/5/154
Submitter  : CIJOML <cijoml@volny.cz>
Handled-By : Markus Rechberger <markus.rechberger@amd.com>
Status     : patches available

