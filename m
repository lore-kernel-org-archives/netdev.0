From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 net-next 0/4] net: low latency sockets
	follow ups
Date: Mon, 17 Jun 2013 15:48:29 -0700 (PDT)
Message-ID: <20130617.154829.1257549505509165519.davem@davemloft.net>
References: <20130614133314.6126.77315.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, ork@mellanox.com, or.gerlitz@gmail.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	hpa@zytor.com, amirv@mellanox.com, linux-kernel@vger.kernel.org,
	alexr@mellanox.com, jesse.brandeburg@intel.com,
	sockperf-dev@googlegroups.com, avnerb@mellanox.com,
	andi@firstfloor.org, eliezer@tamir.org.il,
	bhutchings@solarflare.com, erdnetdev@gmail.com, eilong@broadcom.com
To: eliezer.tamir@linux.intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130614133314.6126.77315.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Date: Fri, 14 Jun 2013 16:33:14 +0300

> Here are three clean up patches, plus one that adds a socket option for LLS.
> 
> Patch 1 converts sysctl_net_ll_poll into an unsigned int
> Patch 2 converts low latency sockets to sched_clock.
> Patch 3 removes the config menu for NET_LL_RX_POLL and defaults to y.
> Patch 4 adds an SO_LL socket option to allow per-socket control of busy polling.

Series applied, thanks.

------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
