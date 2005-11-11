From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/10]: Netfilter IPsec support
Date: Fri, 11 Nov 2005 06:24:23 +0100
Message-ID: <43742B07.9090006@trash.net>
References: <43740D9C.80003@trash.net>
	<20051110.211724.83727693.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20051110.211724.83727693.davem@davemloft.net>
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

David S. Miller wrote:
> Note that I consider this stuff 2.6.16 material.
> 
> We do have a lot of networking changes in 2.6.15
> as it is, and also it would be good for these changes
> to get some review and discussion time.

Sure, they will probably also need some changes for nf_conntrack.
For now I'm happy if we can just agree on the way transport mode
is handled.
