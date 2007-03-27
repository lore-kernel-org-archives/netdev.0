From: Adrian Bunk <bunk@stusta.de>
Subject: [1/5] 2.6.21-rc5: known regressions
Date: Tue, 27 Mar 2007 03:59:29 +0200
Message-ID: <20070327015929.GY16477@stusta.de>
References: <Pine.LNX.4.64.0703251559560.6730@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Oliver Pinter <oliver.pntr@gmail.com>,
	Sid Boyce <g3vbv@blueyonder.co.uk>,
	Boris Mogwitz <boris@macbeth.rhoen.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jose Alberto Reguero <jareguero@telefonica.net>,
	Ingo Molnar <mingo@elte.hu>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, jgarzik@pobox.com,
	netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>,
	Albert Hopkins <kernel@marduk.letterboxes.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:35496 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751483AbXC0B71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2007 21:59:27 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703251559560.6730@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This email lists some known regressions in Linus' tree compared to 2.6.20.

If you find your name in the Cc header, you are either submitter of one
of the bugs, maintainer of an affectected subsystem or driver, a patch
of you caused a breakage or I'm considering you in any other way
possibly involved with one or more of these issues.

Due to the huge amount of recipients, please trim the Cc when answering.


Subject    : crashes in KDE
References : http://bugzilla.kernel.org/show_bug.cgi?id=8157
Submitter  : Oliver Pinter <oliver.pntr@gmail.com>
Status     : unknown


Subject    : kwin dies silently  (sysctl related?)
References : http://lkml.org/lkml/2007/2/28/112
Submitter  : Sid Boyce <g3vbv@blueyonder.co.uk>
             Boris Mogwitz <boris@macbeth.rhoen.de>
Status     : submitter was asked to bisect further


Subject    : problem with sockets
References : http://lkml.org/lkml/2007/3/21/248
Submitter  : Jose Alberto Reguero <jareguero@telefonica.net>
Status     : unknown


Subject    : e1000 resume weirdness
References : http://lkml.org/lkml/2007/3/26/91
Submitter  : Ingo Molnar <mingo@elte.hu>
Handled-By : Jesse Brandeburg <jesse.brandeburg@gmail.com>
             Auke Kok <auke-jan.h.kok@intel.com>
Status     : problem is being debugged


Subject    : forcedeth: sporadic under-load crashes
References : http://lkml.org/lkml/2007/3/26/63
Submitter  : Ingo Molnar <mingo@elte.hu>
Handled-By : Ingo Molnar <mingo@elte.hu>
             Ayaz Abdulla <aabdulla@nvidia.com>
Status     : problem is being debugged


Subject    : forcedeth: skb_over_panic
References : http://bugzilla.kernel.org/show_bug.cgi?id=8058
Submitter  : Albert Hopkins <kernel@marduk.letterboxes.org>
Handled-By : Ayaz Abdulla <aabdulla@nvidia.com>
Patch      : http://bugzilla.kernel.org/show_bug.cgi?id=8058
Status     : patch available



