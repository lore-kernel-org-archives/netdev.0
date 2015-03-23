From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: [bisected regression] e1000e: "Detected Hardware
	Unit Hang"
Date: Mon, 23 Mar 2015 14:58 +0100
Message-ID: <3606797.04xNxe9kJh@storm>
References: <1719052.SGOfRAJhfQ@storm> <2370189.uakqRR7OLn@storm>
	<309B89C4C689E141A5FF6A0C5FB2118B78D72A14@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel <e1000-devel@lists.sourceforge.net>,
	'Linux Netdev List' <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: "Brown, Aaron F" <aaron.f.brown@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <309B89C4C689E141A5FF6A0C5FB2118B78D72A14@ORSMSX101.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi Aaron,

On Saturday, 21. February 2015 01:59:35 Brown, Aaron F wrote:
> Thanks, that (and the multiple bug write-ups on sourceforge) gave me more
> than enough to go on.  I was able to replicate it on a handful of systems
> in my lab.  On effected systems setting up a NAT and stressing the
> interfaces with even moderate traffic levels triggers it pretty quickly. 
> It appears that the NAT part is unnecessary, just setting the systems up
> as a software router and running some traffic across it also triggers it
> giving the same apparent behavior (tx hang, watchdog timeout trace, port
> reset.)
> 
> And with an internal reproduction of the issue I have created an internal
> bug report, described my set of reproductions, referenced the similar
> external ones and assigned it to our current e1000e developer.

just wanted to quickly check if there has been any progress
since the internal bug report has been filed?

Cheers,
Thomas


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
