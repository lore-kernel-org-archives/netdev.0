From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/8] e1000e: reformat comment blocks,
 cosmetic changes only
Date: Fri, 28 Mar 2008 22:16:05 -0400
Message-ID: <47EDA665.8000204@garzik.org>
References: <20080328161503.6562.44329.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080328161503.6562.44329.stgit@localhost.localdomain>
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

Auke Kok wrote:
> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Adjusting the comment blocks here to be code-style compliant. no
> code changes.
> 
> Changed some copyright dates to 2008.
> 
> Indentation fixes.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000e/82571.c   |  105 +++++++---
>  drivers/net/e1000e/Makefile  |    2 
>  drivers/net/e1000e/defines.h |  109 ++++++-----
>  drivers/net/e1000e/e1000.h   |   16 +-
>  drivers/net/e1000e/es2lan.c  |   89 +++++----
>  drivers/net/e1000e/ethtool.c |   97 ++++++----
>  drivers/net/e1000e/hw.h      |  145 +++++++-------
>  drivers/net/e1000e/ich8lan.c |  262 ++++++++++++++++----------
>  drivers/net/e1000e/lib.c     |  213 +++++++++++++--------
>  drivers/net/e1000e/netdev.c  |  428 +++++++++++++++++++++++++++---------------
>  drivers/net/e1000e/param.c   |   33 ++-
>  drivers/net/e1000e/phy.c     |  152 ++++++++++-----
>  12 files changed, 1009 insertions(+), 642 deletions(-)

applied 1-3 of 8 (waiting on responses, for the others)



-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
