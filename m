From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] sky2: skb recycling
Date: Wed, 22 Oct 2008 17:17:37 -0700
Message-ID: <48FFC2A1.8000607@hp.com>
References: <20081020190922.7dd6510a@extreme>	<20081020.221857.209830018.davem@davemloft.net>	<48FE34AF.8050508@hp.com> <48FE386F.8090706@cosmosbay.com>	<20081021133811.68bd5ce1@extreme> <48FFBE19.7010803@hp.com> <20081022170517.051d766f@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:30827 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752414AbYJWARl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 20:17:41 -0400
In-Reply-To: <20081022170517.051d766f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>So we have a bit of "tension" between the desires of an end host vs 
>>those of a router right?
>>
>>rick jones
> 
> 
> Not tension, just means on end host this optimization does nothing.

Its free in terms of added cycles consumed?

rick jones
