From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: Re: [PATCH net-next 5/7] qlcnic: Rename the IRQ description.
Date: Fri, 26 Apr 2013 00:35:25 +0000
Message-ID: <BECD8E8A1B550B48A1BF97C13991F60E2FFCEB@avmb2.qlogic.org>
References: <20130425.192152.930991447232787505.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe004.messaging.microsoft.com ([216.32.181.184]:41226
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757432Ab3DZAfc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 20:35:32 -0400
In-Reply-To: <20130425.192152.930991447232787505.davem@davemloft.net>
Content-Language: en-US
Content-ID: <2298D5AC1566E5458AE5D32D94601B2E@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 4/25/13 4:21 PM, "David Miller" <davem@davemloft.net> wrote:

>From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
>Date: Thu, 25 Apr 2013 23:11:05 +0000
>
>> We will like to add the qlcnic prefix to the above format, as it makes
>>it
>> easier for an end user to identify which driver these entries belongs
>>to,
>> without having to run addition command.
>
>This is illogical, and wrong.
>
>By being different, you are making it MORE DIFFICULT for users because
>they have to specially accomodate your unique conventions.
>
>Please follow what other drivers do.
>
>If you disagree with what the convention is, start a discussion about
>changing it, rather than doing whatever you feel like doing in your
>drivers.

We will follow the convention and make the changes in a future submission.


Thanks,
    Jiten
