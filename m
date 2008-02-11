From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/6] [NET] replace code with FIELD_SIZEOF
Date: Mon, 11 Feb 2008 14:51:54 -0500
Message-ID: <47B0A75A.5040009@garzik.org>
References: <20080211172539.29090.99369.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080211172539.29090.99369.stgit@localhost.localdomain>
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
> From: Julia Lawall <julia@diku.dk>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000/e1000_ethtool.c |    2 +-
>  drivers/net/igb/igb_ethtool.c     |    2 +-
>  drivers/net/ixgb/ixgb_ethtool.c   |    2 +-
>  3 files changed, 3 insertions(+), 3 deletions(-)

applied 1-6 to #upstream-fixes



-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
