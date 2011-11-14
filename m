From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Sweep additional floors of
 strcpy in .get_drvinfo routines
Date: Mon, 14 Nov 2011 00:54:38 -0500 (EST)
Message-ID: <20111114.005438.1105151733849011995.davem@davemloft.net>
References: <20111109195807.440D229004BE@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: cooldavid@cooldavid.org, leedom@chelsio.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	dm@chelsio.com, rl@hellgate.ch, venza@brownhat.org,
	pcnet32@frontier.com, romieu@fr.zoreil.com, divy@chelsio.com
To: raj@tardy.cup.hp.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20111109195807.440D229004BE@tardy>
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
Date: Wed,  9 Nov 2011 11:58:07 -0800 (PST)

> From: Rick Jones <rick.jones2@hp.com>
> 
> Perform another round of floor sweeping, converting the .get_drvinfo
> routines of additional drivers from strcpy to strlcpy along with
> some conversion of sprintf to snprintf.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>

Applied, thanks Rick.

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
