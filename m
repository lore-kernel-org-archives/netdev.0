From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] add new iptables ipt_connbytes match
Date: Sat, 13 Aug 2005 13:58:32 -0700 (PDT)
Message-ID: <20050813.135832.115928361.davem@davemloft.net>
References: <42FC0F01.5090802@trash.net>
	<20050812115622.GD16325@rama.de.gnumonks.org>
	<42FD4AC6.2020506@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net
In-Reply-To: <42FD4AC6.2020506@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] add new iptables ipt_connbytes match
Date: Sat, 13 Aug 2005 03:20:06 +0200

> Harald Welte wrote:
> > Just send two incremental patches to Dave.
> 
> Here they are. The first patch fixes the div64_64 function, the second
> one renames some constants.

Both applied, thanks Patrick.
