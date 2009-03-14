From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [Bug #12868] iproute2 and regressing "ipv6: convert tunnels to net_device_ops"
Date: Sat, 14 Mar 2009 20:20:20 +0100 (CET)
Message-ID: <qm8_cedJGaP.A.vMG.jOCvJB@chimera>
References: <9nR7rAsBwYG.A.iEG.fOCvJB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: Kernel Testers List <kernel-testers@vger.kernel.org>,
	"Jan Engelhardt" <jengelh@medozas.de>,
	"netdev" <netdev@vger.kernel.org>,
	"Stephen Hemminger" <shemminger@vyatta.com>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:41882 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761651AbZCNV6Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 17:58:24 -0400
In-Reply-To: <9nR7rAsBwYG.A.iEG.fOCvJB@chimera>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This message has been generated automatically as a part of a report
of regressions introduced between 2.6.27 and 2.6.28.

The following bug entry is on the current list of known regressions
introduced between 2.6.27 and 2.6.28.  Please verify if it still should
be listed and let me know (either way).


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12868
Subject		: iproute2 and regressing "ipv6: convert tunnels to net_device_ops"
Submitter	: Jan Engelhardt <jengelh@medozas.de>
Date		: 2009-03-09 14:46 (6 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=1326c3d5a4b792a2b15877feb7fb691f8945d203
References	: http://marc.info/?l=linux-netdev&m=123660999632730&w=4


