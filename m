From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: ethernet: intel: i40e: Fix
 missing uapi/linux/dcbnl.h include in i40e_fcoe.c
Date: Tue, 05 Aug 2014 16:45:07 -0700 (PDT)
Message-ID: <20140805.164507.779439224391996731.davem@davemloft.net>
References: <20140805131143.GA29685@ttmp-linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kernelnewbies@kernelnewbies.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, linux-kernel@vger.kernel.org
To: tanure@linux.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20140805131143.GA29685@ttmp-linux>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Lucas Tanure <tanure@linux.com>
Date: Tue, 5 Aug 2014 10:11:43 -0300

> Fix missing include in intel i40e driver. Without this include linux next
> tree won't compile.
> 
> Signed-off-by: Lucas Tanure <tanure@linux.com>

Applied, thank you.

------------------------------------------------------------------------------
Infragistics Professional
Build stunning WinForms apps today!
Reboot your WinForms applications with our WinForms controls. 
Build a bridge from your legacy apps to the future.
http://pubads.g.doubleclick.net/gampad/clk?id=153845071&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
