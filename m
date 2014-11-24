From: nick <xerofoify@gmail.com>
Subject: Re: [linux-nics] FIX ME in e1000_82575.c
Date: Mon, 24 Nov 2014 14:14:31 -0500
Message-ID: <54738397.5050407@gmail.com>
References: <547165BC.2000508@gmail.com>
	<9B4A1B1917080E46B64F07F2989DADD653451A92@ORSMSX114.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux NICS <Linux-nics@isotope.jf.intel.com>,
	"linux-kernel@vger.kernel.or" <linux-kernel@vger.kernel.or>
To: "Fujinaka, Todd" <todd.fujinaka@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <9B4A1B1917080E46B64F07F2989DADD653451A92@ORSMSX114.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Sounds good enough, just a question why is my email bouncing against linux-nics mailing list?
Cheers Nick

On 14-11-24 11:32 AM, Fujinaka, Todd wrote:
> I'm not sure there's much need to actually change the value. It's been the same since 2007 when the log message says, "Removed FIXME comment."
> 
> I think someone forgot to remove the second FIXME comment. I'll send a patch.
> 
> Todd Fujinaka
> Software Application Engineer
> Networking Division (ND)
> Intel Corporation
> todd.fujinaka@intel.com
> (503) 712-4565
> 
> -----Original Message-----
> From: linux-nics-bounces@isotope.jf.intel.com [mailto:linux-nics-bounces@isotope.jf.intel.com] On Behalf Of nick
> Sent: Saturday, November 22, 2014 8:43 PM
> To: Kirsher, Jeffrey T
> Cc: Linux NICS; e1000-devel@lists.sourceforge.net; Vick, Matthew; netdev@vger.kernel.org; Wyborny, Carolyn; linux-kernel@vger.kernel.or
> Subject: [linux-nics] FIX ME in e1000_82575.c
> 
> Greetings Again Jeff,
> I am wondering about sending in a patch to FIX ME in the file, e1000_82575 due to incorrect values in the function, igdb_acquire_swfw_sync_82575. If you or one of the other maintainers at Intel can send me the correct values or a hardware reference for me to find the values, I would be glad to send it a patch fixing these outstanding issues.
> Regards Nick
> _______________________________________________
> Linux-nics mailing list
> Linux-nics@intel.com
> 

------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
