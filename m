From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5 net-next 3/5] tcp: add TCP support for
 low latency receive poll.
Date: Tue, 28 May 2013 06:44:10 -0700
Message-ID: <1369748650.3301.535.camel@edumazet-glaptop>
References: <20130527074351.29882.51106.stgit@ladj378.jer.intel.com>
	<20130527074421.29882.73968.stgit@ladj378.jer.intel.com>
	<1369701413.3301.506.camel@edumazet-glaptop>
	<51A46A21.9060305@linux.intel.com> <51A49FDC.2020608@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Don,
	Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alex Rosenbaum <alexr@mellanox.com>, linux-kernel@vger.kernel.org,
	Eliezer Tamir <eliezer@tamir.org.il>, Andi Kleen <andi@firstfloor.org>,
	Eilon Greenstien <eilong@broadcom.com>, Dave Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <51A49FDC.2020608@linux.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 2013-05-28 at 15:15 +0300, Eliezer Tamir wrote:

> >> How IPv6 is handled ?
> 
> It turns out that adding TCPv6/UDPv6 is very simple.

Yep, I was about to send you the needed lines after my breakfast ;)




------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
