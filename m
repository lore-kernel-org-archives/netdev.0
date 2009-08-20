From: John Dykstra <john.dykstra1-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: 2.6.31-rc6-git5: Reported regressions from 2.6.30
Date: Thu, 20 Aug 2009 20:52:51 +0000
Message-ID: <1250801571.7176.10.camel@Maple>
References: <jCYznkTxcLB.A.EPH.eNIjKB@chimera>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <jCYznkTxcLB.A.EPH.eNIjKB@chimera>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-08-19 at 22:20 +0200, Rafael J. Wysocki wrote:
> Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=14002
> Subject         : WARNING: at net/ipv4/af_inet.c:154
> inet_sock_destruct+0x164/0x1c0()
> Submitter       : Ralf Hildebrandt <ralf.hildebrandt-jq1tPX9l7E6ELgA04lAiVw@public.gmane.org>
> Date            : 2009-08-18 12:37 (2 days old)

That looks similar to the WARNING discussed in [1].

There was no resolution to that thread.  However, [2] points out
possible other occurrences of the problem in 2.6.27, 28 and 29.

--  John

[1]  http://www.spinics.net/lists/netdev/msg103267.html
[2]  http://www.spinics.net/lists/netdev/msg104120.html
