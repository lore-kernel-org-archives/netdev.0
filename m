From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.32-rc4: Reported regressions 2.6.30 -> 2.6.31
Date: Mon, 12 Oct 2009 23:46:11 +0200
Message-ID: <200910122346.11881.rjw@sisk.pl>
References: <56acieJJ2fF.A.nEB.Hzl0KB@chimera>
	<20091012122201.GA31282@gambetta>
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
To: Frederik Deweerdt <frederik.deweerdt@xprog.eu>
Return-path: <dri-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20091012122201.GA31282@gambetta>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=dri-devel>
List-Post: <mailto:dri-devel@lists.sourceforge.net>
List-Help: <mailto:dri-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: dri-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Monday 12 October 2009, Frederik Deweerdt wrote:
> Hi Rafael,
> 
> On Mon, Oct 12, 2009 at 12:41:30AM +0200, Rafael J. Wysocki wrote:
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14185
> > Subject		: Oops in driversbasefirmware_class
> > Submitter	:  <lars_ericsson@telia.com>
> > Date		: 2009-09-17 05:09 (25 days old)
> > First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=6e03a201bbe8137487f340d26aa662110e324b20
> > 
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14253
> > Subject		: Oops in driversbasefirmware_class
> > Submitter	: Lars Ericsson <Lars_Ericsson@telia.com>
> > Date		: 2009-09-16 20:44 (26 days old)
> > References	: http://lkml.org/lkml/2009/9/16/461
> > Handled-By	: Frederik Deweerdt <frederik.deweerdt@xprog.eu>
> > Patch		: http://patchwork.kernel.org/patch/49914/
> > 
> Those two are refering to the same bug.

Thanks, I closed #14185 as a duplicate of #14253.

Best,
Rafael

------------------------------------------------------------------------------
Come build with us! The BlackBerry(R) Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9 - 12, 2009. Register now!
http://p.sf.net/sfu/devconference
--
