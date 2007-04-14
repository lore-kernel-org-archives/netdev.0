From: Adrian Bunk <bunk@stusta.de>
Subject: [1/3] 2.6.21-rc6: known regressions
Date: Sat, 14 Apr 2007 02:36:25 +0200
Message-ID: <20070414003625.GS5907@stusta.de>
References: <Pine.LNX.4.64.0704051944230.6730@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Stephen Clark <Stephen.Clark@seclark.us>, jgarzik@pobox.com,
	linux-ide@vger.kernel.org,
	Michal Jaegermann <michal@ellpspace.math.ualberta.ca>,
	lenb@kernel.org, linux-acpi@vger.kernel.org,
	netdev@vger.kernel.org, Dave Jones <davej@redhat.com>,
	cramerj@intel.com, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com, auke-jan.h.kok@intel.com,
	e1000-devel@lists.sourceforge.net, Ingo Molnar <mingo@elte.hu>,
	Ayaz Abdulla <aabdulla@nvidia.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-ide-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704051944230.6730@woody.linux-foundation.org>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This email lists some known regressions in Linus' tree compared to 2.6.20.

If you find your name in the Cc header, you are either submitter of one
of the bugs, maintainer of an affectected subsystem or driver, a patch
of you caused a breakage or I'm considering you in any other way
possibly involved with one or more of these issues.

Due to the huge amount of recipients, please trim the Cc when answering.


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
Submitter  : Ingo Molnar <mingo@elte.hu>
Handled-By : Ingo Molnar <mingo@elte.hu>
             Ayaz Abdulla <aabdulla@nvidia.com>
Status     : problem is being debugged


