From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NETFILTER]: Fix skb->nf_bridge lifetime issues
Date: Mon, 20 Feb 2006 20:21:27 -0800 (PST)
Message-ID: <20060220.202127.129642897.davem@davemloft.net>
References: <43F98CEE.1080609@trash.net>
	<20060220.200943.51907116.davem@davemloft.net>
	<43FA9440.6070103@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	bdschuym@pandora.be
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net
In-Reply-To: <43FA9440.6070103@trash.net>
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
Date: Tue, 21 Feb 2006 05:17:04 +0100

> I think net-2.6.17 is better, the bridging stuff is really to
> fragile for this to be sure it won't break anything and this
> has never worked so far.

Ok, done.
