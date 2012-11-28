From: Javier Domingo <javierdo1@gmail.com>
Subject: Re: Specific question about packet dropping
Date: Wed, 28 Nov 2012 17:52:12 +0100
Message-ID: <CALZVap=jSEnHCYBp_FxdK=jnPORd_qfiaYGa6gVFmqUDHJ2f5A@mail.gmail.com>
References: <CALZVapnQrH9YvCOh8OnGFs1V28nPfX4p=GK=M0VnqHjZCU8=1Q@mail.gmail.com>
 <50B5F959.5080000@gmail.com> <CALZVapkZpRRh+ruf-QWbv_pFYtZgdx7US7Zc6x0kgMmmAsnAPg@mail.gmail.com>
 <50B60244.9020605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Shan Wei <shanwei88@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:52242 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753284Ab2K1Qwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:52:33 -0500
Received: by mail-vb0-f46.google.com with SMTP id ff1so8248677vbb.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 08:52:33 -0800 (PST)
In-Reply-To: <50B60244.9020605@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have been reviewing and I think I must have confused terms.

Then, inside the kernel, there are no packet drops for legitime ones.
And I suppose that if an app doesn't read from its socket queue, the
kernel will drop them in the socket queue?
Javier Domingo


2012/11/28 Shan Wei <shanwei88@gmail.com>:
> Javier Domingo said, at 2012/11/28 19:50:
>> Thank you very much, I (don't know why) thought the packets were being
>> smashed in the dma memory.
>
> Maybe your kernel/application handles the packets so slower than that
> NIC receives.
>
>>> Best Regards
>>> Shan Wei
>>>
>>>>
>>>> Javier Domingo
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>
>>>
>>>
>>
>
