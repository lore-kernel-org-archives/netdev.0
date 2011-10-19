From: David Miller <davem@davemloft.net>
Subject: Re: BUG in skb_pull with e1000e, PPTP, and L2TP
Date: Wed, 19 Oct 2011 03:51:01 -0400 (EDT)
Message-ID: <20111019.035101.1022527921339689585.davem@davemloft.net>
References: <1318910393.2571.47.camel@edumazet-laptop>
	<20111019.033154.371626230759904957.davem@davemloft.net>
	<1319010435.18562.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, despite@gmail.com
To: eric.dumazet@gmail.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1319010435.18562.3.camel@edumazet-laptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 19 Oct 2011 09:47:15 +0200

> I incorrectly thought this driver was at the same location in net &
> net-next, and I my net-next tree was more convenient to compile this.
> 
> I can respin patch on net tree if you prefer.

No need, I took care of adjusting the paths.

Thanks!

------------------------------------------------------------------------------
All the data continuously generated in your IT infrastructure contains a
definitive record of customers, application performance, security
threats, fraudulent activity and more. Splunk takes this data and makes
sense of it. Business sense. IT sense. Common sense.
http://p.sf.net/sfu/splunk-d2d-oct
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
