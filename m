From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] IPv6: reassembly: replace magic number with macro
 definitions
Date: Wed, 20 Jan 2010 01:32:08 -0800 (PST)
Message-ID: <20100120.013208.258496398.davem@davemloft.net>
References: <4B56A0DD.1010404@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, yoshfuji@linux-ipv6.org,
	kaber@trash.net, eric.dumazet@gmail.com, adobriyan@gmail.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org
To: shanwei@cn.fujitsu.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B56A0DD.1010404@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Wed, 20 Jan 2010 14:21:17 +0800

> 
> Use macro to define high/low thresh value, refer to IPV6_FRAG_TIMEOUT.
> 
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

Patrick you can take this into your tree:

Acked-by: David S. Miller <davem@davemloft.net>
