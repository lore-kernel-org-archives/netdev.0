From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] ixgb: convert uint16_t style integers
	to u16
Date: Sat, 12 Apr 2008 05:08:28 -0400
Message-ID: <48007C0C.4090302@garzik.org>
References: <20080403170625.22624.13870.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080403170625.22624.13870.stgit@localhost.localdomain>
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
> From: Joe Perches <joe@perches.com>
> 
> Conglomerate of 4 separate patches by Joe.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/ixgb/ixgb.h         |   32 +++--
>  drivers/net/ixgb/ixgb_ee.c      |   74 ++++++------
>  drivers/net/ixgb/ixgb_ee.h      |   10 +-
>  drivers/net/ixgb/ixgb_ethtool.c |   50 ++++----
>  drivers/net/ixgb/ixgb_hw.c      |  144 ++++++++++++------------
>  drivers/net/ixgb/ixgb_hw.h      |  234 ++++++++++++++++++++-------------------
>  drivers/net/ixgb/ixgb_main.c    |   60 +++++-----
>  7 files changed, 302 insertions(+), 302 deletions(-)

applied 1-2



-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
