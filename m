From: James Morris <jmorris@namei.org>
Subject: Re: networking probs in next-20081203
Date: Tue, 16 Dec 2008 00:28:08 +1100 (EST)
Message-ID: <alpine.LRH.1.10.0812160021030.10723@tundra.namei.org>
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
	<1229117086.3134.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Daniel J Walsh <dwalsh@redhat.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Paris <eparis@parisplace.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1229117086.3134.22.camel@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, 12 Dec 2008, Stephen Smalley wrote:

> Maybe pass flags down to security_sb_kern_mount() and skip the check in
> the MS_KERNMOUNT case?

Seems like a good solution.

-- 
James Morris
<jmorris@namei.org>

------------------------------------------------------------------------------
SF.Net email is Sponsored by MIX09, March 18-20, 2009 in Las Vegas, Nevada.
The future of the web can't happen without you.  Join us at MIX09 to help
pave the way to the Next Web now. Learn more and register at
http://ad.doubleclick.net/clk;208669438;13503038;i?http://2009.visitmix.com/
