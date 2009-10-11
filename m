From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: 2.6.32-rc4: Reported regressions 2.6.30 -> 2.6.31
Date: Sun, 11 Oct 2009 18:24:22 -0500
Message-ID: <4AD26926.9030306@lwfinger.net>
References: <56acieJJ2fF.A.nEB.Hzl0KB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: DRI <dri-devel@lists.sourceforge.net>,
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
In-Reply-To: <56acieJJ2fF.A.nEB.Hzl0KB@chimera>
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

On 10/11/2009 05:41 PM, Rafael J. Wysocki wrote:
> [Note:
>   10 new reports in the last 10 days, but fortunately we're fixing them faster
>   than they're being reported.]

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14181
> Subject		: b43 causes panic at ifconfig down / shutdown
> Submitter	: Jeremy Huddleston <jeremyhu@freedesktop.org>
> Date		: 2009-09-15 18:34 (27 days old)

A patch to fix this one is in the hands of the OP. It should be tested
within the next couple of days.

Larry
