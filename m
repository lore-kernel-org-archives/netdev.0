From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4 net-next 04/26] gianfar: Support the
 get_ts_info ethtool method.
Date: Fri, 06 Apr 2012 00:35:48 -0400 (EDT)
Message-ID: <20120406.003548.102675436176396606.davem@davemloft.net>
References: <cover.1333529504.git.richardcochran@gmail.com>
	<c268d71203b066b9052a8cabd5f6c71de2a8fa77.1333529506.git.richardcochran@gmail.com>
	<CAP=VYLrNBjHgPJFzwBrQ4=5rouCD81PLW4f_TPZMkF7yObUdcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mporter@solarflare.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, jacob.e.keller@intel.com,
	john.ronciak@intel.com, bhutchings@solarflare.com,
	linux-next@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <CAP=VYLrNBjHgPJFzwBrQ4=5rouCD81PLW4f_TPZMkF7yObUdcA@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Fri, 6 Apr 2012 00:25:32 -0400

> Needs an include of <linux/net_tstamp.h> ?

I've pushed out that fix.

------------------------------------------------------------------------------
For Developers, A Lot Can Happen In A Second.
Boundary is the first to Know...and Tell You.
Monitor Your Applications in Ultra-Fine Resolution. Try it FREE!
http://p.sf.net/sfu/Boundary-d2dvs2
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
