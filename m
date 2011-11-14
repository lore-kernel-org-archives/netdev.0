From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Sweep the last of the active
 .get_drvinfo floors under ethernet/
Date: Mon, 14 Nov 2011 14:22:21 -0500 (EST)
Message-ID: <20111114.142221.426237349118940895.davem@davemloft.net>
References: <20111114181325.217C72900307@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dwang2@cisco.com, netdev@vger.kernel.org, roprabhu@cisco.com,
	e1000-devel@lists.sourceforge.net, benve@cisco.com
To: raj@tardy.cup.hp.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20111114181325.217C72900307@tardy>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: raj@tardy.cup.hp.com (Rick Jones)
Date: Mon, 14 Nov 2011 10:13:25 -0800 (PST)

> From: Rick Jones <rick.jones2@hp.com>
> 
> This round of floor sweeping converts strncpy calls in various .get_drvinfo
> routines to the preferred strlcpy.  It also does a modicum of other
> cleaning in those routines.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>

Applied, thanks for taking care of this.

------------------------------------------------------------------------------
RSA(R) Conference 2012
Save $700 by Nov 18
Register now
http://p.sf.net/sfu/rsa-sfdev2dev1
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
