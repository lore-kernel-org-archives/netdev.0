From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] changing value of NETDEV_ALIGN to cacheline size
Date: Mon, 15 May 2006 16:01:56 -0700
Message-ID: <44690864.1000706@hp.com>
References: <20060515080258.bdcfba5f.rdunlap@xenotime.net>	<20060515.143011.36635008.davem@davemloft.net>	<4468F50B.9000102@hp.com> <20060515.154955.114682456.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdunlap@xenotime.net, borntrae@de.ibm.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:23434 "EHLO palrel11.hp.com")
	by vger.kernel.org with ESMTP id S1750724AbWEOXB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 19:01:59 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060515.154955.114682456.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Mon, 15 May 2006 14:39:23 -0700
> 
> 
>>How about:
> 
> 
> How about, just leave it alone? :-)

That would work too :) but I guess I figured based on the reason given 
just before I posted, for why setting to L1_CACHE_SIZE was wrong that 
there was an implication that tweaking it might be right.

rick
