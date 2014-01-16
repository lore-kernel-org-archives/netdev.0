From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: Re: [PATCH 1/2 v3] ixgbe: define
 IXGBE_MAX_VFS_DRV_LIMIT macro and cleanup const 63
Date: Thu, 16 Jan 2014 02:51:55 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B7312DF41@ORSMSX101.amr.corp.intel.com>
References: <1389795148-341-1-git-send-email-ethan.kernel@gmail.com>
	<309B89C4C689E141A5FF6A0C5FB2118B7312DA20@ORSMSX101.amr.corp.intel.com>
	<CABawtvNEDjTJAjJ9TeEvZd7+2kD=H6zA23T-aQo3uVm5SUEhCQ@mail.gmail.com>
	<309B89C4C689E141A5FF6A0C5FB2118B7312DE7D@ORSMSX101.amr.corp.intel.com>
	<CABawtvNSpDU+pjdJOpCB8kyQqA7B9N4g0S_yPgQaZnB3h0+nFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "ethan.kernel@gmail.com" <ethan.kernel@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <CABawtvNSpDU+pjdJOpCB8kyQqA7B9N4g0S_yPgQaZnB3h0+nFg@mail.gmail.com>
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

On Thu, 2014-01-16 at 09:58 +0800, Ethan Zhao wrote:
> Aaron,
> 
> Is this your net-next repo ? if so, I rebuild the patch with this repo
> right now .
> git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git
> 
> Thanks,
> Ethan
> 
Only sort of.  Jeff uses it to push patches up, but I don't have an
account there so am simply sending them up the old fashioned way, via
email, hence it is probably not getting updated while Jeff is out.

As long as your patch can apply cleanly to Dave Miller's net-next tree I
should be able to pull it into our internal ones.
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
