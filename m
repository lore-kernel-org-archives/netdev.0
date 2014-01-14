From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: Re: [PATCH] [trivial] ixgbe: Fix format string in
	ixgbe_fcoe.c
Date: Tue, 14 Jan 2014 22:25:14 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B7312CAA3@ORSMSX101.amr.corp.intel.com>
References: <1389716082-23395-1-git-send-email-standby24x7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "trivial@kernel.org" <trivial@kernel.org>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: "standby24x7@gmail.com" <standby24x7@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1389716082-23395-1-git-send-email-standby24x7@gmail.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 2014-01-15 at 01:14 +0900, Masanari Iida wrote:
> cppcheck detected following warning in ixgbe_fcoe.c
> (warning) %d in format string (no. 1) requires 'int' but the
> argument type is 'unsigned int'.
> 
> Signed-off-by: Masanari Iida <standby24x7@gmail.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-) 

Thanks Masanari, I have added it to our internal queue for testing.
------------------------------------------------------------------------------
CenturyLink Cloud: The Leader in Enterprise Cloud Services.
Learn Why More Businesses Are Choosing CenturyLink Cloud For
Critical Workloads, Development Environments & Everything In Between.
Get a Quote or Start a Free Trial Today. 
http://pubads.g.doubleclick.net/gampad/clk?id=119420431&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
