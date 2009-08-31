From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 1/5] ucc_geth: Fix NULL pointer dereference in
	uec_get_ethtool_stats()
Date: Mon, 31 Aug 2009 19:35:11 +1000
Message-ID: <1251711311.15353.2.camel@pasglop>
References: <20090827173547.GA1580@oksana.dev.rtsoft.ru>
	<20090830.215224.203201252.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: scottwood@freescale.com, netdev@vger.kernel.org, timur@freescale.com,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20090830.215224.203201252.davem@davemloft.net>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Sun, 2009-08-30 at 21:52 -0700, David Miller wrote:
> All 5 patches applied to net-next-2.6
> 
> I would have liked to have seen at least one powerpc ACK for
> patch #2 but these were posted more than a week ago, the
> patch looks pretty reasonable, and we can't wait forever for
> stuff like this.

The qe stuff ? Well, that's entirely Kumar's domain, but Anton
patches tend to be of good quality so I wouldn't have too much
second thoughts here.

Cheers,
Ben.
