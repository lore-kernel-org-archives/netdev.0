From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [XFRM]: Fix SNAT-related crash in xfrm4_output_finish
Date: Wed, 15 Feb 2006 15:14:50 -0800 (PST)
Message-ID: <20060215.151450.79708438.davem@davemloft.net>
References: <43F3640B.6070809@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	herbert@gondor.apana.org.au
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net
In-Reply-To: <43F3640B.6070809@trash.net>
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
Date: Wed, 15 Feb 2006 18:25:31 +0100

> This patch fixes the crash in xfrm4_output_finish reported by
> multiple people.

Looks good, applied.

Thanks Patrick.
