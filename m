From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: Re: 2.6.32-rc1-git2: Reported regressions from 2.6.31
Date: Fri, 02 Oct 2009 13:08:59 +0530
Message-ID: <1254469139.3531.19.camel@ht.satnam>
References: <9UCePxij8cB.A.VCG.-3SxKB@chimera>
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
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756544AbZJBHkn@vger.kernel.org>
In-Reply-To: <9UCePxij8cB.A.VCG.-3SxKB@chimera>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Rafael,

On Thu, 2009-10-01 at 21:26 +0200, Rafael J. Wysocki wrote:
> [Notes:
> 
>  * Here's the first summary report of known regressions from 2.6.31.  There's
>    not too many of them at the moment, which is nice.
> 
>  * We're still getting quite a number of reports of regressions from 2.6.30 and
>    it's been that way since 2.6.31 was released.  For details please see the
>    summary report of regressions 2.6.30 -> 2.6.31 that will follow shortly.]
> 
> This message contains a list of some regressions from 2.6.31, for which there
> are no fixes in the mainline I know of.  If any of them have been fixed already,
> please let me know.
> 
> If you know of any other unresolved regressions from 2.6.31, please let me know
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
>   2009-10-02       22       15           9
> 
> 
> Unresolved regressions
> ----------------------
> 
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14299
> Subject		: oops in wireless, iwl3945 related?
> Submitter	: Pavel Machek <pavel@ucw.cz>
> Date		: 2009-09-29 17:12 (3 days old)
> References	: http://marc.info/?l=linux-kernel&m=125424439725743&w=4
> 

If you add one more entry say "Suspected commit :" then it will be great
and will solve regressions much faster. You can request submitter to
submit 'suspected commit' by git bisect and also specify git bisect
links like : (for more information about git bisect check
http://kerneltrap.org/node/11753)

Thanks,
--
JSR
