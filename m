From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NETFILTER]: Fix skb->nf_bridge lifetime issues
Date: Mon, 20 Feb 2006 20:09:43 -0800 (PST)
Message-ID: <20060220.200943.51907116.davem@davemloft.net>
References: <43F97342.9050806@trash.net>
	<43F98CEE.1080609@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	bdschuym@pandora.be
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net
In-Reply-To: <43F98CEE.1080609@trash.net>
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
Date: Mon, 20 Feb 2006 10:33:34 +0100

> This time compile tested and s/nfct/nf_bridge/ above.

Want me to push this into net-2.6 now that Bart has ACK'd it?

Thanks.
