From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] fix kernel crash with macvtap on top
	of LRO
Date: Thu, 07 Feb 2013 13:14:20 -0500 (EST)
Message-ID: <20130207.131420.1211188723341167971.davem@davemloft.net>
References: <1360193660.32217.39.camel@deadeye.wl.decadent.org.uk>
	<1360207111.28557.47.camel@edumazet-glaptop>
	<1360254046.3605.8.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jitendra.kalsaria@qlogic.com, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, eilong@broadcom.com,
	john.r.fastabend@intel.com, john.ronciak@intel.com,
	sony.chacko@qlogic.com, linux-driver@qlogic.com,
	linux-kernel@vger.kernel.org, jacob.e.keller@intel.com
To: bhutchings@solarflare.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1360254046.3605.8.camel@bwh-desktop.uk.solarflarecom.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 7 Feb 2013 16:20:46 +0000

> If the consensus is still that we must preserve packets exactly (aside
> from the usual modifications by IP routers) then LRO should be disabled
> on all devices for which forwarding is enabled.

I believe this is still undoubtedly the consensus.

------------------------------------------------------------------------------
Free Next-Gen Firewall Hardware Offer
Buy your Sophos next-gen firewall before the end March 2013 
and get the hardware for free! Learn more.
http://p.sf.net/sfu/sophos-d2d-feb
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
