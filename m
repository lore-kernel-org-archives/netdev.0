From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4 net-next 00/26] ethtool: support time
 stamping and phc clocks
Date: Wed, 04 Apr 2012 05:29:16 -0400 (EDT)
Message-ID: <20120404.052916.1495763141439052807.davem@davemloft.net>
References: <cover.1333529504.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mporter@solarflare.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, jacob.e.keller@intel.com,
	john.ronciak@intel.com, bhutchings@solarflare.com
To: richardcochran@gmail.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Richard Cochran <richardcochran@gmail.com>
Date: Wed,  4 Apr 2012 10:59:15 +0200

> * Changes in V4:
>   - drop two patches requiring out of tree support
>   - added Ben's Reviewed-by tag on two commit messages
> * Changes in V3:
>   - works without ethtool_ops
>   - does not require special privileges
>   - neaten user space tool output

Applied, let's see if this one compiles :-)

------------------------------------------------------------------------------
Better than sec? Nothing is better than sec when it comes to
monitoring Big Data applications. Try Boundary one-second 
resolution app monitoring today. Free.
http://p.sf.net/sfu/Boundary-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
