From: Haiying Wang <Haiying.Wang@freescale.com>
Subject: Re: [PATCH 1/4] net/phy/marvell: update m88e1111 support for SGMII
	mode
Date: Tue, 02 Jun 2009 10:03:59 -0400
Message-ID: <1243951440.2927.7.camel@r54964-12.am.freescale.net>
References: <12435168302841-git-send-email-Haiying.Wang@freescale.com>
	<20090601.025151.146454973.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20090601.025151.146454973.davem@davemloft.net>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-06-01 at 02:51 -0700, David Miller wrote:
> Patch 3 of this series doesn't apply cleanly to net-next-2.6
> so I'm dropping the entire patch set.

> Also, in patch 3 you put your signoff in the Subject line.
> 
> Please fix all of this up and resubmit your patch series.

I only verified the first three patches could be applied to your
net-2.6, did not verify whether they could be applied for net-next-2.6.
Sorry.
I've fixed the patch3 against net-next-2.6 now, and will resubmit the
patches.
But the patch4 can not be applied to your net-next-2.6 since there is
not 8569mds support in that tree. Hope Kumar can pick up the patch 4.

Thanks.

Haiying
