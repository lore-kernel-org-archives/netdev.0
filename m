From: Adrian Bunk <bunk@stusta.de>
Subject: [2/6] 2.6.21-rc3: known regressions
Date: Tue, 13 Mar 2007 13:50:03 +0100
Message-ID: <20070313125003.GS18731@stusta.de>
References: <Pine.LNX.4.64.0703062050570.5963@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Len Brown <lenb@kernel.org>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@coreworks.de,
	netdev@vger.kernel.org, Pavel Machek <pavel@ucw.cz>,
	Marcel Holtmann <marcel@holtmann.org>, maxk@qualcomm.com,
	bluez-devel@lists.sf.net,
	Albert Hopkins <kernel@marduk.letterboxes.org>,
	Ayaz Abdulla <aabdulla@nvidia.com>, jgarzik@pobox.com
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:57958 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753246AbXCMMuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2007 08:50:00 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703062050570.5963@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This email lists some known regressions in Linus' tree compared to 2.6.20.

If you find your name in the Cc header, you are either submitter of one
of the bugs, maintainer of an affectected subsystem or driver, a patch
of you caused a breakage or I'm considering you in any other way
possibly involved with one or more of these issues.

Due to the huge amount of recipients, please trim the Cc when answering.


Subject    : ipv6 crash
References : http://lkml.org/lkml/2007/3/10/2
Submitter  : Len Brown <lenb@kernel.org>
Status     : unknown


Subject    : ThinkPad X60: bluetooth hardlocks
References : http://lkml.org/lkml/2007/3/2/85
Submitter  : Pavel Machek <pavel@ucw.cz>
Handled-By : Marcel Holtmann <marcel@holtmann.org>
Status     : unknown


Subject    : forcedeth: skb_over_panic
References : http://bugzilla.kernel.org/show_bug.cgi?id=8058
Submitter  : Albert Hopkins <kernel@marduk.letterboxes.org>
Handled-By : Ayaz Abdulla <aabdulla@nvidia.com>
Status     : problem is being debugged


