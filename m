From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] ip_conntrack_helper_h323.c: EXPORT_SYMBOL'ed
 functions shouldn't be static
Date: Thu, 23 Mar 2006 22:08:57 -0800 (PST)
Message-ID: <20060323.220857.24982378.davem@davemloft.net>
References: <20060324000801.GM22727@stusta.de>
	<20060323.161314.59991770.davem@davemloft.net>
	<44234B10.5040802@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	zhaojignmin@hotmail.com, linux-kernel@vger.kernel.org, bunk@stusta.de
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net
In-Reply-To: <44234B10.5040802@trash.net>
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
Date: Fri, 24 Mar 2006 02:27:44 +0100

> I guess I should send it to lkml anyway. It boots fine, I couldn't
> figure out how to compare checksums, since the time of compilation
> and a couple other dynamically generated strings end up in the binary.

This looks fine, I'll push it in during my next round of networking
updates.
