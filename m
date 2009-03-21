From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: [Bug #12868] iproute2 and regressing "ipv6: convert tunnels to net_device_ops"
Date: Sat, 21 Mar 2009 18:07:29 +0100 (CET)
Message-ID: <fnEpM0mQZjO.A.o3E.S8TxJB@chimera>
References: <HPkmj74uawF.A.iqE.M8TxJB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Jan Engelhardt" <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>,
	"netdev" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Stephen Hemminger" <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <HPkmj74uawF.A.iqE.M8TxJB@chimera>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This message has been generated automatically as a part of a report
of regressions introduced between 2.6.27 and 2.6.28.

The following bug entry is on the current list of known regressions
introduced between 2.6.27 and 2.6.28.  Please verify if it still should
be listed and let me know (either way).


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12868
Subject		: iproute2 and regressing "ipv6: convert tunnels to net_device_ops"
Submitter	: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
Date		: 2009-03-09 14:46 (13 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=1326c3d5a4b792a2b15877feb7fb691f8945d203
References	: http://marc.info/?l=linux-netdev&m=123660999632730&w=4
