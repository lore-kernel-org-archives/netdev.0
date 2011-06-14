From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: Re: [PATCH 2/9] xen: convert to 64 bit stats interface
Date: Tue, 14 Jun 2011 17:07:56 -0400
Message-ID: <20110614210756.GA22304@dumpdata.com>
References: <20110609005356.160260858@vyatta.com>
	<20110609005417.385577995@vyatta.com>
	<1307584605.22348.527.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	xen-devel@lists.xensource.com,
	Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>,
	"David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>,
	Ian Campbell <Ian.Campbell@eu.citrix.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
Content-Disposition: inline
In-Reply-To: <1307584605.22348.527.camel@localhost>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 09, 2011 at 02:56:45AM +0100, Ben Hutchings wrote:
> On Wed, 2011-06-08 at 17:53 -0700, Stephen Hemminger wrote:
> > Convert xen driver to 64 bit statistics interface.
> > This driver was already counting packet per queue in a 64 bit value so not
> > a huge change.
> [...]
> 
> I think this driver will need to use u64_stats_sync.

Ian?
