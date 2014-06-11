From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] net: sh_eth: Fix two issues in sh_eth_rx()
Date: Wed, 11 Jun 2014 15:37:33 -0700 (PDT)
Message-ID: <20140611.153733.758226399072849408.davem@davemloft.net>
References: <539653E4.9080808@renesas.com>
	<20140611.151555.814836065790733997.davem@davemloft.net>
	<5398D658.2090100@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshihiro.shimoda.uh@renesas.com, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <5398D658.2090100@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Thu, 12 Jun 2014 02:21:12 +0400

> Hello.
> 
> On 06/12/2014 02:15 AM, David Miller wrote:
> 
>>> I used the latest net.git repository.
>>>   commit id = 87757a917b0b3c0787e0563c679762152be81312
>>>   (net: force a list_del() in unregister_netdevice_many())
> 
>>> I tested these patches on r8a7790.
> 
>>> Changes from v1:
>>>   - Remove unnecessary parens in patch 1.
> 
>> Applied, thanks.
> 
>    Eh, haven't had time to look at these patches in detail... :-/

Sorry, we can do follow-up changes or a flat-out revert if you want.
