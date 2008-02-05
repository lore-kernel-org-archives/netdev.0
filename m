From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 8/8] ixgbe: add real-time traffic counters
Date: Tue, 05 Feb 2008 13:33:19 -0500
Message-ID: <47A8ABEF.3070909@garzik.org>
References: <20080201235841.31474.49421.stgit@localhost.localdomain>
	<20080201235919.31474.147.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080201235919.31474.147.stgit@localhost.localdomain>
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
> From: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>
> 
> Just like our other drivers before we can switch ixgbe to
> provide real-time packet/byte counters to the stack easily.
> 
> Signed-off-by: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/ixgbe/ixgbe_main.c |   15 +++++++++++----
>  1 files changed, 11 insertions(+), 4 deletions(-)

applied 1-8



-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
