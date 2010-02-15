From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: 2.6.33-rc8: Reported regressions 2.6.31 -> 2.6.32
Date: Mon, 15 Feb 2010 01:20:10 +0100
Message-ID: <4B78933A.8020203@tvk.rwth-aachen.de>
References: <fQEllunEdO.A.-LB.HyIeLB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7BIT
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
	DRI <dri-devel@lists.sourceforge.net>, segfault2@hotmail.com
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:34088 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753674Ab0BOAUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2010 19:20:17 -0500
In-reply-to: <fQEllunEdO.A.-LB.HyIeLB@chimera>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rafael J. Wysocki schrieb:
> This message contains a list of some post-2.6.31 regressions introduced before
> 2.6.32, for which there are no fixes in the mainline known to the tracking team.
> If any of them have been fixed already, please let us know.
> 
> If you know of any other unresolved post-2.6.31 regressions, please let us know
> either and we'll add them to the list.  Also, please let us know if any
> of the entries below are invalid.
> 
> Each entry from the list will be sent additionally in an automatic reply to
> this message with CCs to the people involved in reporting and handling the
> issue.
> 
> 
> Listed regressions statistics:
> [...]
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14898
> Subject		: ksoftirqd problem
> Submitter	: Nico <segfault2@hotmail.com>
> Date		: 2009-12-13 19:05 (64 days old)
> References	: http://marc.info/?l=linux-kernel&m=126073114325690&w=4

Maybe that's related to http://marc.info/?l=linux-netdev&m=126582880812703.

Regards
 Damian
