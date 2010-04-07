From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: 2.6.34-rc3-git6: Reported regressions from 2.6.33
Date: Wed, 7 Apr 2010 17:53:19 -0400
Message-ID: <20100407215319.GA25932@tuxdriver.com>
References: <6Pphclm24fK.A.lSF.qsPvLB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48991 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755885Ab0DGWAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 18:00:17 -0400
Content-Disposition: inline
In-Reply-To: <6Pphclm24fK.A.lSF.qsPvLB@chimera>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 07, 2010 at 11:08:30PM +0200, Rafael J. Wysocki wrote:

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=15551
> Subject		: WARNING: at net/mac80211/work.c:811 ieee80211_work_work+0x7f/0xde8 [mac80211]()
> Submitter	: Alex Zhavnerchik <alex.vizor@gmail.com>
> Date		: 2010-03-16 22:03 (23 days old)

I sent a pull request with the patch for this to Dave M. today. :-)

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
