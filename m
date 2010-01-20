From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] IPv6: reassembly: replace magic number with macro
 definitions
Date: Wed, 20 Jan 2010 10:37:35 +0100
Message-ID: <4B56CEDF.9030305@trash.net>
References: <4B56A0DD.1010404@cn.fujitsu.com> <20100120.013208.258496398.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: shanwei@cn.fujitsu.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	yoshfuji@linux-ipv6.org, eric.dumazet@gmail.com,
	adobriyan@gmail.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100120.013208.258496398.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Shan Wei <shanwei@cn.fujitsu.com>
> Date: Wed, 20 Jan 2010 14:21:17 +0800
> 
>> Use macro to define high/low thresh value, refer to IPV6_FRAG_TIMEOUT.
>>
>>
>> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> 
> Patrick you can take this into your tree:
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Will do, thanks.

