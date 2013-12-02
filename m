From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH] sctp: check the rto_min and rto_max
Date: Mon, 2 Dec 2013 09:33:26 +0800
Message-ID: <529BE366.2060504@huawei.com>
References: <5299BCB8.6070409@huawei.com> <20131130.160847.361995350346508364.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>,
	<dingtianhong@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:16804 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500Ab3LBBec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Dec 2013 20:34:32 -0500
In-Reply-To: <20131130.160847.361995350346508364.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/1 5:08, David Miller wrote:
> From: wangweidong <wangweidong1@huawei.com>
> Date: Sat, 30 Nov 2013 18:23:52 +0800
> 
>> rto_min should be smaller than rto_max while rto_max should be larger
>> than rto_min. so just add the check.
>>
>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> 
> Please fix your submission process such that your real full name
> appears in the "From: " field of your patch emails, instead of
> just "wangweidong", which is your username not your real full
> name.
> 
> I'm not applying your patches until you correct this and submit
> the patch properly, thanks.
> 

Ok, I will fix it in v2.
Thanks.

> 
