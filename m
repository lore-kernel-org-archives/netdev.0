From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] firmware: convert e100 driver to
	request_firmware()
Date: Sun, 15 Jun 2008 14:07:13 -0400
Message-ID: <48555A51.1010301@garzik.org>
References: <1213522966.26255.433.camel@pmac.infradead.org>	
	<48555677.7040209@garzik.org>
	<1213552319.26255.498.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Jaswinder Singh <jaswinderlinux@gmail.com>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1213552319.26255.498.camel@pmac.infradead.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

David Woodhouse wrote:
> On Sun, 2008-06-15 at 13:50 -0400, Jeff Garzik wrote:
>> NAK - firmware should not be stored in a separate directory from the 
>> driver to which it is intimately tied.
> 
> Your objection is noted, but ignored.

Then your patch is noted, and ignored.

	Jeff




-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
