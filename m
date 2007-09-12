From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [net-2.6.24][NETNS][patch 1/3] fix export symbols
Date: Wed, 12 Sep 2007 14:57:33 +0200
Message-ID: <46E7E23D.1050201@fr.ibm.com>
References: <20070912123811.075269132@mai.toulouse-stg.fr.ibm.com> <20070912124414.640551634@mai.toulouse-stg.fr.ibm.com> <20070912.055307.23027518.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, containers@lists.osdl.org,
	netdev@vger.kernel.org, markn@au1.ibm.com, benjamin.thery@bull.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:31149 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966196AbXILM7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 08:59:17 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id l8CCxFTw158300
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 12:59:15 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8CCxF0j2015358
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 14:59:15 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8CCxEuP004933
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 14:59:15 +0200
In-Reply-To: <20070912.055307.23027518.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: dlezcano@fr.ibm.com
> Date: Wed, 12 Sep 2007 14:38:12 +0200
> 
>> From: Daniel Lezcano <dlezcano@fr.ibm.com>
>>
>> Add the appropriate EXPORT_SYMBOLS for proc_net_create,
>> proc_net_fops_create and proc_net_remove to fix errors when
>> compiling allmodconfig
>>
>> Signed-off-by: Mark Nelson <markn@au1.ibm.com>
>> Acked-by: Benjamin Thery <benjamin.thery@bull.net>
> 
> Applied to net-2.6.24, thanks.
> 
> Why aren't you signing off on these patches?  Please
> do so in the future.
> 
> Because "From: " usually means you are the patch author, and I can't
> tell who wrote these patches, you or these other people listed in the
> signoff area.
> 

Sorry for that, I will take care of that next time. Thanks.
