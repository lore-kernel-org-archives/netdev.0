From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 0/4] net: fec: Code cleanup
Date: Sat, 27 Sep 2014 18:55:01 -0400 (EDT)
Message-ID: <20140927.185501.2157704066172736196.davem@davemloft.net>
References: <1411458058-18934-1-git-send-email-b38611@freescale.com>
	<20140926.160602.1429816882470314568.davem@davemloft.net>
	<ea65c2c86f264e49940038df21121c9e@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Frank.Li@freescale.com
To: fugang.duan@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37055 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178AbaI0WzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Sep 2014 18:55:05 -0400
In-Reply-To: <ea65c2c86f264e49940038df21121c9e@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Date: Sat, 27 Sep 2014 09:51:52 +0000

> From: David Miller <davem@davemloft.net> Sent: Saturday, September 27, 2014 4:06 AM
>>To: Duan Fugang-B38611
>>Cc: netdev@vger.kernel.org; Li Frank-B20596
>>Subject: Re: [PATCH v1 0/4] net: fec: Code cleanup
>>
>>From: Fugang Duan <b38611@freescale.com>
>>Date: Tue, 23 Sep 2014 15:40:54 +0800
>>
>>> This patches does several things:
>>>   - Fixing multiqueue issue.
>>>   - Removing the unnecessary errata workaround.
>>>   - Aligning the data buffer dma map/unmap size.
>>>   - Freeing resource after probe failed.
>>
>>Series applied to net-next, thanks.
>>
>>Please always explicitly state what tree you expect your patches to be
>>applied to in the future.
> 
> No special requirement, just follow the normal rel flow.

That doesn't mean anything to me.

You must state what tree your patches apply properly to, and thus
where you expect them to be intergrated.
