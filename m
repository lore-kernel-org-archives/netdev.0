From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6] 2/2:  Fix NAT helper locking
Date: Fri, 03 Sep 2004 17:53:21 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <41389371.2030009@trash.net>
References: <20040903070234.GQ26263@sunbeam.de.gnumonks.org>
	<20040903002453.77beee16.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>, netdev@oss.sgi.com,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040903002453.77beee16.davem@davemloft.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

>Applied both patches, but the first had serious offsets
>and the second had to be applied by hand due to rejects
>against the current 2.6.x sources.
>
>Ummm... wow what ancient tree did you patch against
>Harald?  The tree you patched against didn't even have the
>skb_header_pointer() changes in it, that's caveman
>era :-)  That's what caused the rejects.
>  
>
My fault, I put the patches into patch-o-matic about two or
three weeks ago and didn't expect they wouldn't apply anymore
so quickly :)

>
>Anyways, I merged it all in cleanly.
>
Thanks.

Patrick
