From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2]IP: Send an ICMP "Fragment Reassembly Timeout"
 message when enabling connection track
Date: Sat, 23 Jan 2010 01:58:08 -0800 (PST)
Message-ID: <20100123.015808.196441033.davem@davemloft.net>
References: <4B5844F2.30104@trash.net>
	<4B590BE3.40509@cn.fujitsu.com>
	<4B599084.1060406@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shanwei@cn.fujitsu.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, eric.dumazet@gmail.com,
	david@blue-labs.org, jorge@dti2.net, opurdila@ixiacom.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B599084.1060406@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 22 Jan 2010 12:48:20 +0100

> Shan Wei wrote:
>> [PATCH v2]IP: Send an ICMP "Fragment Reassembly Timeout" message when enabling connection track
 ...
>> The patch has been tested on both host type and route type.
> 
> Looks good to me. Would you mind adding a similar change to IPv6
> (net/ipv6/netfilter/nf_conntrack_reasm.c)?

Applied to net-next-2.6, thanks.
