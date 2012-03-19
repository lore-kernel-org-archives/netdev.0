From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] igbvf: Use ETH_ALEN
Date: Mon, 19 Mar 2012 16:58:29 -0400 (EDT)
Message-ID: <20120319.165829.2194332887711322729.davem@davemloft.net>
References: <cover.1332128181.git.joe@perches.com>
	<49b440b7f5a9fa85ed5278e2663541283e32cad8.1332128181.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <49b440b7f5a9fa85ed5278e2663541283e32cad8.1332128181.git.joe@perches.com>
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
Date: Sun, 18 Mar 2012 20:37:58 -0700

> Remove an unnecessary #define and use memcpy
> instead of a loop to copy an ethernet address.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.

------------------------------------------------------------------------------
This SF email is sponsosred by:
Try Windows Azure free for 90 days Click Here 
http://p.sf.net/sfu/sfd2d-msazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
