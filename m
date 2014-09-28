From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH v1 0/4] net: fec: Code cleanup
Date: Sun, 28 Sep 2014 03:39:40 +0000
Message-ID: <1779baf41a334eada2d11db0a474641b@BY2PR03MB377.namprd03.prod.outlook.com>
References: <1411458058-18934-1-git-send-email-b38611@freescale.com>
	<20140926.160602.1429816882470314568.davem@davemloft.net>
	<ea65c2c86f264e49940038df21121c9e@BLUPR03MB373.namprd03.prod.outlook.com>
 <20140927.185501.2157704066172736196.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0105.outbound.protection.outlook.com ([157.56.110.105]:63195
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752180AbaI1Djn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Sep 2014 23:39:43 -0400
In-Reply-To: <20140927.185501.2157704066172736196.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net> Sent: Sunday, September 28, 2014 6:55 AM
>To: Duan Fugang-B38611
>Cc: netdev@vger.kernel.org; Li Frank-B20596
>Subject: Re: [PATCH v1 0/4] net: fec: Code cleanup
>
>From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
>Date: Sat, 27 Sep 2014 09:51:52 +0000
>
>> From: David Miller <davem@davemloft.net> Sent: Saturday, September 27,
>> 2014 4:06 AM
>>>To: Duan Fugang-B38611
>>>Cc: netdev@vger.kernel.org; Li Frank-B20596
>>>Subject: Re: [PATCH v1 0/4] net: fec: Code cleanup
>>>
>>>From: Fugang Duan <b38611@freescale.com>
>>>Date: Tue, 23 Sep 2014 15:40:54 +0800
>>>
>>>> This patches does several things:
>>>>   - Fixing multiqueue issue.
>>>>   - Removing the unnecessary errata workaround.
>>>>   - Aligning the data buffer dma map/unmap size.
>>>>   - Freeing resource after probe failed.
>>>
>>>Series applied to net-next, thanks.
>>>
>>>Please always explicitly state what tree you expect your patches to be
>>>applied to in the future.
>>
>> No special requirement, just follow the normal rel flow.
>
>That doesn't mean anything to me.
>
>You must state what tree your patches apply properly to, and thus where
>you expect them to be intergrated.

I see. It is better let them enter to 3.17 (rc7).

Thanks,
Andy 
