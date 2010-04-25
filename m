From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e100: Fix the TX workqueue race
Date: Sat, 24 Apr 2010 19:58:59 -0700 (PDT)
Message-ID: <20100424.195859.193729555.davem@davemloft.net>
References: <20100423.163127.62645049.davem@davemloft.net>
	<20100423.163545.157549100.davem@davemloft.net>
	<20100424121127.084b9766@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: alan@linux.intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20100424121127.084b9766@linux.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Alan Cox <alan@linux.intel.com>
Date: Sat, 24 Apr 2010 12:11:27 +0100

> No idea why it won't apply - I guess net has diverged from -next in
> this area. Other problem is not typing "stg ref" before "stg export"

It has, the debug print statement above the lines you are changing are
completely different.

Please generate this patch against net-2.6 so I can apply it, thanks
Alan.

------------------------------------------------------------------------------
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
