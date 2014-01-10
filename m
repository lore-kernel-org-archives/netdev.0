From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/23] netfilter: nft_ct: load both IPv4 and IPv6
 conntrack modules for NFPROTO_INET
Date: Fri, 10 Jan 2014 14:48:13 -0500 (EST)
Message-ID: <20140110.144813.659408334812475090.davem@davemloft.net>
References: <1389314142-17969-9-git-send-email-pablo@netfilter.org>
	<52D05AC6.20000@cogentembedded.com>
	<20140110194235.GA9253@macbook.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140110194235.GA9253@macbook.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 10 Jan 2014 19:42:36 +0000

> I can see you're looking out for the important stuff. I consistently
> used this style in nftables so I'm not going to change it here.

Patrick, please follow the coding style conventions of the kernel,
these issues are important for long term sanity of the kernel tree.

It helps people who are looking at the netfilter code who perhaps
do not do so usually.  Do you really want to use a different style
and therefore make your code harder to read for them?  Really?

Your code being consistent with your code only is less important than
all of the networking looking the same.

Thank you.
