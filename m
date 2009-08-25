From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: 2.6.31-rc6-git5: Reported regressions from 2.6.30
Date: Tue, 25 Aug 2009 18:25:00 -0500
Message-ID: <4A9472CC.2020508@lwfinger.net>
References: <jCYznkTxcLB.A.EPH.eNIjKB@chimera> <4A8F12CE.9090601@lwfinger.net>
	<200908220002.03707.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>, DRI <dri-devel@lists.sourceforge.net>,
        Linux SCSI List <linux-scsi@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux Wireless List <linux-wireless@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Natalie Protasevich <protasnb@gmail.com>,
        Linux ACPI <linux-acpi@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Kernel Testers List <kernel-testers@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Linux PM List <linux-pm@lists.linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
In-Reply-To: <200908220002.03707.rjw@sisk.pl>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Rafael J. Wysocki wrote:
> On Friday 21 August 2009, Larry Finger wrote:
>> Rafael J. Wysocki wrote:
>>
>>> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13960
>>> Subject		: rtl8187 not connect to wifi
>>> Submitter	: okias <d.okias@gmail.com>
>>> Date		: 2009-08-10 19:16 (10 days old)
>> The patch for this one was sent from Linville to DaveM earlier today,
>> and should be sent to mainline in the near future.
>>
>> AFAIK, the OP has not yet tested the patch, but I think I was able to
>> reproduce the problem, and the patch did fit it for me.
> 
> Thanks for the update.
> 
> Can you please close the bug when the patch is merged?

The patch hit mainline as commit
1a9937b7f07ab6e35515e32a7625f0ba50ab7670. The bug has been closed.

Larry
