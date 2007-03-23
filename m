From: Adrian Bunk <bunk@stusta.de>
Subject: [5/5] 2.6.21-rc4: known regressions (v2)
Date: Fri, 23 Mar 2007 19:50:37 +0100
Message-ID: <20070323185037.GS752@stusta.de>
References: <Pine.LNX.4.64.0703160925270.26106@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	CIJOML <cijoml@volny.cz>, v4l-dvb-maintainer@linuxtv.org,
	Tino Keitel <tino.keitel@gmx.de>,
	Oliver Neukum <oneukum@suse.de>, greg@kroah.com,
	linux-usb-devel@lists.sourceforge.net,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Takashi Iwai <tiwai@suse.de>, perex@suse.cz,
	alsa-devel@alsa-project.org,
	Albert Hopkins <kernel@marduk.letterboxes.org>,
	Ayaz Abdulla <aabdulla@nvidia.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:32913 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753342AbXCWSud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 14:50:33 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703160925270.26106@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This email lists some known regressions in Linus' tree compared to 2.6.20.

If you find your name in the Cc header, you are either submitter of one
of the bugs, maintainer of an affectected subsystem or driver, a patch
of you caused a breakage or I'm considering you in any other way
possibly involved with one or more of these issues.

Due to the huge amount of recipients, please trim the Cc when answering.


Subject    : Oops when changing DVB-T adapter
References : http://lkml.org/lkml/2007/3/9/212
Submitter  : CIJOML <cijoml@volny.cz>
Status     : unknown


Subject    : USB: iPod doesn't work
References : http://lkml.org/lkml/2007/3/21/320
Submitter  : Tino Keitel <tino.keitel@gmx.de>
Handled-By : Oliver Neukum <oneukum@suse.de>
Status     : problem is being debuggged


Subject    : snd_intel8x0: divide error: 0000
References : http://lkml.org/lkml/2007/3/5/252
Submitter  : Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Handled-By : Takashi Iwai <tiwai@suse.de>
Status     : problem is being debugged


Subject    : forcedeth: skb_over_panic
References : http://bugzilla.kernel.org/show_bug.cgi?id=8058
Submitter  : Albert Hopkins <kernel@marduk.letterboxes.org>
Handled-By : Ayaz Abdulla <aabdulla@nvidia.com>
Patch      : http://bugzilla.kernel.org/show_bug.cgi?id=8058
Status     : patch available


