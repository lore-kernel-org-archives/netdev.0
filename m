From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] IPv6: reassembly:  replace  magic number with macro
 definitions
Date: Wed, 20 Jan 2010 10:43:28 +0100
Message-ID: <4B56D040.8020808@trash.net>
References: <4B56A0DD.1010404@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, yoshfuji@linux-ipv6.org, eric.dumazet@gmail.com,
	adobriyan@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B56A0DD.1010404@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shan Wei wrote:
> Use macro to define high/low thresh value, refer to IPV6_FRAG_TIMEOUT.

Also applied, thanks.
