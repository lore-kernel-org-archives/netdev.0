From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ethernet: Use bool function
 returns of true/false instead of 1/0
Date: Tue, 31 Mar 2015 14:10:04 -0400 (EDT)
Message-ID: <20150331.141004.825741028516673439.davem@davemloft.net>
References: <20150325215525.GA26868@athens>
	<20150329.121655.2092434262655191613.davem@davemloft.net>
	<1427678712.2715.52.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, linux.nics@intel.com,
	hariprasad@chelsio.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, bruce.w.allan@intel.com,
	linux-kernel@vger.kernel.org, varun@chelsio.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	kbuild-all@01.org, ariel.elior@qlogic.com,
	fengguang.wu@intel.com, michal.simek@xilinx.com, soren.brinkmann@xilinx.com
To: joe@perches.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1427678712.2715.52.camel@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun, 29 Mar 2015 18:25:12 -0700

> Use bool constants as the return values instead of 1 and 0.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.

------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
