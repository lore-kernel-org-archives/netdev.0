From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sfc: Replace memset with eth_zero_addr
Date: Wed, 20 Jan 2016 05:25:45 -0500 (EST)
Message-ID: <20160120.052545.1239193729611285581.davem@davemloft.net>
References: <1453246074-1054-1-git-send-email-tanure@linux.com>
	<569F56FE.6070303@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tanure@linux.com, sshah@solarflare.com,
	linux-net-drivers@solarflare.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bkenward@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <569F56FE.6070303@solarflare.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bert Kenward <bkenward@solarflare.com>
Date: Wed, 20 Jan 2016 09:44:30 +0000

> On 19/01/16 23:27, Lucas Tanure wrote:
>> Use eth_zero_addr to assign the zero address to the given address array
>> instead of memset when second argument is address of zero.
>> 
>> Signed-off-by: Lucas Tanure <tanure@linux.com>
>> ---
> 
> Acked-by: Bert Kenward <bkenward@solarflare.com>
> 
> ... although net-next is still closed I think.

Correct.
