From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH next] staging-slicoss: Kill directly reference of netdev->priv
Date: Mon, 08 Dec 2008 08:32:43 +0800
Message-ID: <493C6B2B.9080809@cn.fujitsu.com>
References: <493946EB.7000308@cn.fujitsu.com> <20081206.235950.120548600.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gregkh@suse.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62802 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753200AbYLHAcr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Dec 2008 19:32:47 -0500
In-Reply-To: <20081206.235950.120548600.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-12-7 15:59:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Fri, 05 Dec 2008 23:21:15 +0800
> 
>> Simply replace netdev->priv with netdev_priv().
>>
>> Compile test only.
>>
>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> 
> Also applied, thanks Wang.
> 
> Wang, how much more of this stuff do you estimate we still
> have to fix up before we can really kill off ->priv?
> 
> Just curious...
> 

Only one left, as I grepped last week.
I will finish it this week.

