From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] drivers/net/: Spelling fixes
Date: Mon, 17 Dec 2007 16:15:52 -0500
Message-ID: <1197926152.3798.263.camel@shinybook.infradead.org>
References: <5703e57f925f31fc0eb38873bd7f10fc44f99cb4.1197918891.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Pavel Roskin <proski@gnu.org>,
	Eugene Surovegin <ebs@ebshome.net>,
	Geoff Levand <geoffrey.levand@am.sony.com>,
	David Gibson <hermes@gibson.dropbear.id.au>,
	orinoco-devel@lists.sourceforge.net, Yi Zhu <yi.zhu@intel.com>,
	Jaroslav Kysela <perex@perex.cz>, linuxppc-dev@ozlabs.org,
	Paul Mackerras <paulus@samba.org>,
	Peter De Shrijver <p2@ace.ulyssis.student.kuleuven.ac.be>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	bonding-devel@lists.sourceforge.net,
	Andy Gospodarek <andy@greyhouse.net>,
	"Amit S. Kale" <amitkale@netxen.com>,
	ipw2100-devel@lists.sourceforge.net,
	atl1-devel@lists.sourceforge.net, Chris Snook <csnook@redhat.com>,
	Masakazu Mokuno <mokuno@sm.sony.co.jp>,
	libertas-dev@lists.infradead.org, Dan Williams <dcbw@redhat.com>,
	Dale Farnsworth <dale@farnsworth.org>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Manish Lachw
To: Joe Perches <joe@perches.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <5703e57f925f31fc0eb38873bd7f10fc44f99cb4.1197918891.git.joe@perches.com>
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

On Mon, 2007-12-17 at 11:40 -0800, Joe Perches wrote:
>  drivers/net/wireless/libertas/cmd.c            |    4 ++--
>  drivers/net/wireless/libertas/scan.c           |    4 ++--

I will apply these to the libertas tree; please remove them from any
resend of this patch.

If we were using git properly, it wouldn't matter -- I could just let
the patch go in upstream and when it gets merged, it'll be fine. But for
some reason we don't use git for network driver development; we pretend
it's the 1990s and we deal with sets of patches instead. So having this
simple change applied in an upstream tree would cause lots of pain, as
far as I can tell.

-- 
dwmw2


-------------------------------------------------------------------------
SF.Net email is sponsored by:
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services
for just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
