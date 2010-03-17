From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net/e100.c: Use
 pr_<level> and netif_<level>
Date: Tue, 16 Mar 2010 21:31:49 -0700 (PDT)
Message-ID: <20100316.213149.00701940.davem@davemloft.net>
References: <cover.1266893507.git.joe@perches.com>
	<9929d2391002231833j65008a1ev1d2297672a39a483@mail.gmail.com>
	<1267478181.12641.142.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	linux-kernel@vger.kernel.org, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com, gallatin@myri.com, brice@myri.com
To: joe@perches.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1267478181.12641.142.camel@Joe-Laptop.home>
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
Date: Mon, 01 Mar 2010 13:16:21 -0800

> Convert DPRINTK, commonly used for debugging, to netif_<level>
> Remove #define PFX
> Use #define pr_fmt
> Consistently use no periods for non-sentence logging messages
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.

------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
