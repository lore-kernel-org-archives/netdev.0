From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.31-rc6-git5: Reported regressions from 2.6.30
Date: Thu, 20 Aug 2009 23:28:24 +0200
Message-ID: <200908202328.24252.rjw@sisk.pl>
References: <jCYznkTxcLB.A.EPH.eNIjKB@chimera> <1250801571.7176.10.camel@Maple>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755478AbZHTV1f@vger.kernel.org>
In-Reply-To: <1250801571.7176.10.camel@Maple>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 20 August 2009, John Dykstra wrote:
> On Wed, 2009-08-19 at 22:20 +0200, Rafael J. Wysocki wrote:
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=14002
> > Subject         : WARNING: at net/ipv4/af_inet.c:154
> > inet_sock_destruct+0x164/0x1c0()
> > Submitter       : Ralf Hildebrandt <ralf.hildebrandt@charite.de>
> > Date            : 2009-08-18 12:37 (2 days old)
> 
> That looks similar to the WARNING discussed in [1].
> 
> There was no resolution to that thread.  However, [2] points out
> possible other occurrences of the problem in 2.6.27, 28 and 29.
> 
> --  John
> 
> [1]  http://www.spinics.net/lists/netdev/msg103267.html
> [2]  http://www.spinics.net/lists/netdev/msg104120.html

Thanks for the information.

So I'll drop this from the list, since it most probably is not a recent thing.

Best,
Rafael
