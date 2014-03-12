From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/9] igbvf: Convert uses of
 __constant_<foo> to <foo>
Date: Wed, 12 Mar 2014 15:29:58 -0400 (EDT)
Message-ID: <20140312.152958.463449212083110588.davem@davemloft.net>
References: <cover.1394644825.git.joe@perches.com>
	<52ad53c6822c19de67480e8b3e36201a30cab308.1394644825.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	linux-kernel@vger.kernel.org, john.ronciak@intel.com
To: joe@perches.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <52ad53c6822c19de67480e8b3e36201a30cab308.1394644825.git.joe@perches.com>
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
Date: Wed, 12 Mar 2014 10:22:33 -0700

> The use of __constant_<foo> has been unnecessary for quite awhile now.
> 
> Make these uses consistent with the rest of the kernel.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Will let the Intel folks pick this up.

------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
