From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: 2.6.32-rc7-git1: Reported regressions 2.6.30 -> 2.6.31
Date: Mon, 16 Nov 2009 17:30:37 -0600
Message-ID: <4B01E09D.3020608@lwfinger.net>
References: <ipicVA1QUFF.A.zWB.1mdALB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
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
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <ipicVA1QUFF.A.zWB.1mdALB@chimera>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/16/2009 04:58 PM, Rafael J. Wysocki wrote:
> This message contains a list of some regressions introduced between 2.6.30 and
> 2.6.31, for which there are no fixes in the mainline I know of.  If any of them
> have been fixed already, please let me know.
> 
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14181
> Subject		: b43 causes panic at ifconfig down / shutdown
> Submitter	: Jeremy Huddleston <jeremyhu@freedesktop.org>
> Date		: 2009-09-15 18:34 (63 days old)

This one is fixed by commit d50bae33d1358b909ade05ae121d83d3a60ab63f in
mainline. The patch was also sent to stable.

Larry
