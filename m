From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Add PHY IRQ support to the 'sh_eth' driver
Date: Thu, 19 Dec 2013 19:11:18 -0500 (EST)
Message-ID: <20131219.191118.2238735452700839030.davem@davemloft.net>
References: <201312200138.09307.sergei.shtylyov@cogentembedded.com>
	<52B37684.5030206@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36988 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756295Ab3LTALT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 19:11:19 -0500
In-Reply-To: <52B37684.5030206@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 20 Dec 2013 01:43:16 +0300

> On 12/20/2013 01:38 AM, Sergei Shtylyov wrote:
> 
>>     This patchset adds support for passing PHY's IRQ to the 'sh_eth'
>>     driver from
>> the platform code and removes now useless code that hinders the PHY
>> IRQ handing
>> by philib.
> 
>    Ugh, forgot to mention it's against DaveM's 'net-next.git' repo.

No need, series applied, thanks.
