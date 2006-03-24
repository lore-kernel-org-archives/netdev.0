From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6 patch] ip_conntrack_helper_h323.c: make
 get_h245_addr()static
Date: Thu, 23 Mar 2006 23:55:57 -0800 (PST)
Message-ID: <20060323.235557.88280922.davem@davemloft.net>
References: <20060324000916.GN22727@stusta.de>
	<BAY109-DAV122F44146DB217251703AEB3DF0@phx.gbl>
	<20060324075511.GV22727@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	zhaojignmin@hotmail.com, linux-kernel@vger.kernel.org,
	zhaojingmin@hotmail.com
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: bunk@stusta.de
In-Reply-To: <20060324075511.GV22727@stusta.de>
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

From: Adrian Bunk <bunk@stusta.de>
Date: Fri, 24 Mar 2006 08:55:11 +0100

> The point is:
> There have been many occasions where people have said "I will need this 
> soon" in many different places in the kernel, and one year later it was 
> still unused.
> 
> If it will be needed at some point in the future, reverting my patch
> will be trivial.

Agreed.
