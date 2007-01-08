From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: 2.6.20-rc4: known regressions with patches
	available
Date: Mon, 08 Jan 2007 01:33:38 +0100
Message-ID: <1168216418.12025.11.camel@violet>
References: <Pine.LNX.4.64.0701062216210.3661@woody.osdl.org>
	<20070108002555.GP20714@stusta.de>
Reply-To: BlueZ development <bluez-devel@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	Ayaz Abdulla <aabdulla@nvidia.com>, Michael Reske <micha@gmx.com>,
	Pavel Machek <pavel@ucw.cz>, netdev@vger.kernel.org, gregkh@suse.de,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Robert Hancock <hancockr@shaw.ca>,
	Linus Torvalds <torvalds@osdl.org>, Brice Goglin <brice@myri.com>,
	bluez-devel@lists.sf.net, linux-pci@atrey.karlin.mff.cuni.cz,
	jgarzik@pobox.com
Return-path: <bluez-devel-bounces@lists.sourceforge.net>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20070108002555.GP20714@stusta.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=bluez-devel>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: bluez-devel-bounces@lists.sourceforge.net
Errors-To: bluez-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi Adrian,

> This email lists some known regressions in 2.6.20-rc4 compared to 2.6.19
> with patches available.
> 
> If you find your name in the Cc header, you are either submitter of one
> of the bugs, maintainer of an affectected subsystem or driver, a patch
> of you caused a breakage or I'm considering you in any other way possibly
> involved with one or more of these issues.
> 
> Due to the huge amount of recipients, please trim the Cc when answering.
> 
> 
> Subject    : bluetooth oopses because of multiple kobject_add()
> References : http://lkml.org/lkml/2007/1/2/101
> Submitter  : Pavel Machek <pavel@ucw.cz>
> Handled-By : Marcel Holtmann <marcel@holtmann.org>
> Patch      : http://lkml.org/lkml/2007/1/2/147
> Status     : patch available

the patch has been forwarded to Dave Miller.

Regards

Marcel



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
