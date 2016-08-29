From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH v2 net-next] documentation: Document issues with VMs and
 XPS and drivers enabling it on their own
Date: Mon, 29 Aug 2016 09:26:35 -0700
Message-ID: <32d356cc-a7c7-2349-88a5-ab4652272ba1@hpe.com>
References: <20160825225543.BFA562900836@tardy>
 <CALx6S35myS9QTA7QhnDpL8ybC2c6S8LOp47iNEGS_zxXXVf4mw@mail.gmail.com>
 <20160826.213550.1069021753459989756.davem@davemloft.net>
 <CALx6S356MGsEiJkuTEfPLv=KGdfqZoz6Q2AJhPqp9yx-t2g15A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Tom Herbert <tom@herbertland.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3428.houston.hpe.com ([15.241.140.76]:31837 "EHLO
        g4t3428.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753682AbcH2Q0h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 12:26:37 -0400
In-Reply-To: <CALx6S356MGsEiJkuTEfPLv=KGdfqZoz6Q2AJhPqp9yx-t2g15A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/2016 12:41 PM, Tom Herbert wrote:
> On Fri, Aug 26, 2016 at 9:35 PM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <tom@herbertland.com>
>> Date: Thu, 25 Aug 2016 16:43:35 -0700
>>
>>> This seems like it will only confuse users even more. You've clearly
>>> identified an issue, let's figure out how to fix it.
>>
>> I kinda feel the same way about this situation.
>
> I'm working on XFS (as the transmit analogue to RFS). We'll track
> flows enough so that we should know when it's safe to move them.

Is the XFS you are working on going to subsume XPS or will the two 
continue to exist in parallel a la RPS and RFS?

rick jones
