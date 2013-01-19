From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net/hyperv: fix wrong length of mac address
Date: Sat, 19 Jan 2013 11:02:41 -0500 (EST)
Message-ID: <20130119.110241.1939146667938397430.davem@davemloft.net>
References: <20130118083031.GA2303@ppwaskie-mobl2.amr.corp.intel.com>
	<1358563929-10942-1-git-send-email-kongjianjun@gmail.com>
	<5fc6e66ddc034250a4e510784266b063@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kongjianjun@gmail.com, kys@microsoft.com, netdev@vger.kernel.org,
	devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47272 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498Ab3ASQCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2013 11:02:43 -0500
In-Reply-To: <5fc6e66ddc034250a4e510784266b063@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Sat, 19 Jan 2013 15:07:14 +0000

>> From: Amos Kong
> 
>> Sent: Friday, January 18, 2013 9:52 PM
>> To: davem@davemloft.net; KY Srinivasan; Haiyang Zhang
>> Cc: netdev@vger.kernel.org; devel@linuxdriverproject.org; Amos Kong
>> Subject: [PATCH v3] net/hyperv: fix wrong length of mac address
>> 
>> This patch fixed wrong mac length, it should be ETH_ALEN,
>> also replaced the hardcode 6 in hyperv_net.h
>> 
>> Signed-off-by: Amos Kong <kongjianjun@gmail.com>
>> ---
>> v2: update commitlog, fix cc list
>> v3: fix hardcode length in hyperv_net.h
>> ---
> 
>  Acked-by: Haiyang Zhang <haiyangz@microsoft.com>

Applied, thanks.
