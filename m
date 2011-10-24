From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] xen/netback: Enable netback on HVM
	guests
Date: Mon, 24 Oct 2011 05:34:19 -0400 (EDT)
Message-ID: <20111024.053419.1995560587557035685.davem@davemloft.net>
References: <1319124957-32269-1-git-send-email-dgdegra@tycho.nsa.gov>
	<1319124957-32269-6-git-send-email-dgdegra@tycho.nsa.gov>
	<1319448669.3385.161.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dgdegra@tycho.nsa.gov,
	xen-devel@lists.xensource.com, david.vrabel@citrix.com,
	konrad.wilk@oracle.com
To: Ian.Campbell@citrix.com
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <1319448669.3385.161.camel@zakaz.uk.xensource.com>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Mon, 24 Oct 2011 10:31:08 +0100

> On Thu, 2011-10-20 at 16:35 +0100, Daniel De Graaf wrote:
>> Signed-off-by: Daniel De Graaf <dgdegra@tycho.nsa.gov>
> 
> Acked-by: Ian Campbell <ian.campbell@citrix.com>
> 
> Normally netback patches would go in via the networking subsystem
> maintainer's tree but since this depends on core Xen patches from this
> series and is unlikely to conflict with anything in the net-next tree I
> suspect it would make more sense for Konrad to take this one.
> 
> David (Miller) does that work for you?

Yes, it does.
