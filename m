From: Frans Pop <elendil@planet.nl>
Subject: Re: [PATCH 00/09] net: remove trailing spaces in
	messages
Date: Wed, 24 Mar 2010 22:30:31 +0100
Message-ID: <201003242230.34217.elendil@planet.nl>
References: <201003241840.18701.elendil@planet.nl>
	<20100324.141158.43422101.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, samuel@sortiz.org,
	e1000-devel@lists.sourceforge.net, per.liden@ericsson.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, allan.stephens@windriver.com,
	benh@kernel.crashing.org
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20100324.141158.43422101.davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wednesday 24 March 2010, David Miller wrote:
> All applied, but I have to make some fixups.
>
> For example, GIT warns about trailing whitespace on any lines that you
> touched so I had to fix those up before putting them into the tree.

I did wonder about fixing that or not. But as the surrounding code also has 
tons of trailing whitespace, I chose to leave things consistently messy.

I'll remove at least trailing whitespace next time.

Thanks David.

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
