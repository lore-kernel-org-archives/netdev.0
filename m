From: Zhang Rui <rui.zhang@intel.com>
Subject: Re: 2.6.29-rc8: Reported regressions from 2.6.28
Date: Mon, 16 Mar 2009 09:02:53 +0800
Message-ID: <1237165373.2807.140.camel@rzhang-dt>
References: <MiincthRUSI.A.eKC.F4BvJB@chimera>
Mime-Version: 1.0
Content-Type: text/plain
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
	Linux SCSI List <linux-scsi@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <MiincthRUSI.A.eKC.F4BvJB@chimera>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2009-03-15 at 03:01 +0800, Rafael J. Wysocki wrote:
> This message contains a list of some regressions from 2.6.28, for which there
> are no fixes in the mainline I know of.  If any of them have been fixed already,
> please let me know.
> 
> If you know of any other unresolved regressions from 2.6.28, please let me know
> either and I'll add them to the list.  Also, please let me know if any of the
> entries below are invalid.
> 
> Each entry from the list will be sent additionally in an automatic reply to
> this message with CCs to the people involved in reporting and handling the
> issue.
> 
> 
> Listed regressions statistics:
> 
>   Date          Total  Pending  Unresolved
>   ----------------------------------------
>   2009-03-14      124       36          32
>   2009-03-03      108       33          28
>   2009-02-24       95       32          24
>   2009-02-14       85       33          27
>   2009-02-08       82       45          36
>   2009-02-04       66       51          39
>   2009-01-20       38       35          27
>   2009-01-11       13       13          10
> 
> 
> Unresolved regressions
> ----------------------

> Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=12831
> Subject         : Hot/Fn Keys do not work EEEPC 1000HE (eeepc_laptop)
> Submitter       : Matthew <pyther@pyther.net>
> Date            : 2009-03-07 10:05 (8 days old)

patch is available at
http://bugzilla.kernel.org/show_bug.cgi?id=12831#c11

thanks,
rui

