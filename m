From: Shan Wei <shanwei88@gmail.com>
Subject: Re: Specific question about packet dropping
Date: Wed, 28 Nov 2012 20:23:32 +0800
Message-ID: <50B60244.9020605@gmail.com>
References: <CALZVapnQrH9YvCOh8OnGFs1V28nPfX4p=GK=M0VnqHjZCU8=1Q@mail.gmail.com> <50B5F959.5080000@gmail.com> <CALZVapkZpRRh+ruf-QWbv_pFYtZgdx7US7Zc6x0kgMmmAsnAPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Javier Domingo <javierdo1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:53822 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754655Ab2K1MXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 07:23:43 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so9685845pbc.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 04:23:42 -0800 (PST)
In-Reply-To: <CALZVapkZpRRh+ruf-QWbv_pFYtZgdx7US7Zc6x0kgMmmAsnAPg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Javier Domingo said, at 2012/11/28 19:50:
> Thank you very much, I (don't know why) thought the packets were being
> smashed in the dma memory.

Maybe your kernel/application handles the packets so slower than that
NIC receives. 

>> Best Regards
>> Shan Wei
>>
>>>
>>> Javier Domingo
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
>>
> 
