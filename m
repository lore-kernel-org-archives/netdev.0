From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: networking probs in next-20081203
Date: Fri, 12 Dec 2008 02:51:47 -0800
Message-ID: <m1d4fxmzss.fsf@frodo.ebiederm.org>
References: <49381644.8020502@intel.com>
	<20081204175236.GA19808@x200.localdomain>
	<1228414280.11091.54.camel@moss-spartans.epoch.ncsc.mil>
	<20081204.102138.123959105.davem@davemloft.net>
	<1228419142.11091.90.camel@moss-spartans.epoch.ncsc.mil>
	<1228421219.11091.94.camel@moss-spartans.epoch.ncsc.mil>
	<m1bpvrslk0.fsf@frodo.ebiederm.org>
	<1228486339.20274.3.camel@localhost.localdomain>
	<alpine.LRH.1.10.0812112139340.25553@tundra.namei.org>
	<20081212052420.GA14948@x200.localdomain>
	<alpine.LRH.1.10.0812122022520.32426@tundra.namei.org>
	<alpine.LRH.1.10.0812122028470.32426@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Daniel J Walsh <dwalsh@redhat.com>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Smalley <sds@tycho.nsa.gov>, Alexey Dobriyan <adobriyan@gmail.com>
To: James Morris <jmorris@namei.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.LRH.1.10.0812122028470.32426@tundra.namei.org> (James
	Morris's message of "Fri, 12 Dec 2008 20:29:43 +1100 (EST)")
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

James Morris <jmorris@namei.org> writes:

> On Fri, 12 Dec 2008, James Morris wrote:
>
>> It seems the problem is that the /proc/net mountpoint is now labeled as 
>> proc_t.
>
> Actually, that's not the problem, it's the same on a normal kernel.

To confirm what you are saying.  There is something wrong with the bug fix?

Eric

------------------------------------------------------------------------------
SF.Net email is Sponsored by MIX09, March 18-20, 2009 in Las Vegas, Nevada.
The future of the web can't happen without you.  Join us at MIX09 to help
pave the way to the Next Web now. Learn more and register at
http://ad.doubleclick.net/clk;208669438;13503038;i?http://2009.visitmix.com/
