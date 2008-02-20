From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] igb: Fix panic with NICs with 1000BASE-SX
	PHY
Date: Wed, 20 Feb 2008 11:52:20 -0500
Message-ID: <47BC5AC4.9020007@garzik.org>
References: <20080219182441.12033.64731.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	bill.hayes@hp.com, andy@greyhouse.net
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080219182441.12033.64731.stgit@localhost.localdomain>
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
> From: Bill Hayes <bill.hayes@hp.com>
> 
> This patch eliminates a kernel panic with the igb driver in 2.6.25-rc2 when 
> running on a Intel 82575 Ethernet controller with a 1000BASE-SX PHY.  The 
> panic does not happen with the 1000BASE-T PHY, only with a SX connection.  
> 
> Signed-off-by: Bill Hayes <bill.hayes@hp.com>
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

applied



-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
