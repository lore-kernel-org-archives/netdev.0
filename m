From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] sky2: skb recycling
Date: Tue, 21 Oct 2008 12:59:43 -0700
Message-ID: <48FE34AF.8050508@hp.com>
References: <20081020190922.7dd6510a@extreme> <20081020.221857.209830018.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:25118 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbYJUT7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 15:59:48 -0400
In-Reply-To: <20081020.221857.209830018.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Mon, 20 Oct 2008 19:09:22 -0700
> 
> 
>>Add support for recycling tx buffers into receive buffers.
>>This is experimental at this point.
>>
>>Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> 
> Experimental, but do you have any performance data at all?
> Just curious...

I've not had a good emily litella moment all day so I'll ask - is there 
really that much in the way of suitable skb's which are completely free 
after transmit completion?

rick jones
