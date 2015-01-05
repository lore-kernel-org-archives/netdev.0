From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 00/11] A flow API
Date: Sun, 04 Jan 2015 21:17:13 -0800
Message-ID: <54AA1E59.6030309@gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32> <CAJ3xEMikET4Yh88CYb1q5wsFQzakZsyqpPYxropQf2TwYdJg3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, sfeldma@gmail.com,
	=?UTF-8?B?SmnFmcOtIFDDrQ==?= =?UTF-8?B?cmtv?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	simon.horman@netronome.com,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:51064 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750986AbbAEFR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 00:17:29 -0500
Received: by mail-ob0-f172.google.com with SMTP id va8so59418259obc.3
        for <netdev@vger.kernel.org>; Sun, 04 Jan 2015 21:17:28 -0800 (PST)
In-Reply-To: <CAJ3xEMikET4Yh88CYb1q5wsFQzakZsyqpPYxropQf2TwYdJg3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2015 12:30 AM, Or Gerlitz wrote:
> On Wed, Dec 31, 2014 at 9:45 PM, John Fastabend
> <john.fastabend@gmail.com> wrote:
>> So... I could continue to mull over this and tweak bits and pieces
>> here and there but I decided its best to get a wider group of folks
>> looking at it and hopefulyl with any luck using it so here it is.
> [...]
>> I could use some help reviewing
> [...]
>
> Hi John,
>
> It would be very helpful to get access to the actual patches, I don't
> see them on the netdev patchwork queue, and assume
> it's b/c this is still in RFC stage. Cloning your github tree and
> looking there, I see some earlier/WIP versions of the code, but it's
> not
> the submitted patches.
>

The netdev mailed patches should be there (didn't check) I'm guessing
you just need to set the filters correctly. There is an "Action
Required" filter that you most likely need to remove I think it is on
by default. Seeing I already commented on the series indicating I would
need a v2 to address some fixes I'm guessing its already been cleared
from the queue.

> Or.
>
> [1] https://github.com/jrfastab/flow-net-next.git
>

That link is a bit out of date here I pushed the exact series I sent
to a git repo here,

https://github.com/jrfastab/rocker-net-next

All update it tomorrow with some feedback though.

-- 
John Fastabend         Intel Corporation
