From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH v2 net-next 1/5] GRE: Refactor GRE tunneling code.
Date: Mon, 25 Mar 2013 12:30:46 -0700
Message-ID: <CALnjE+rjnWs7z3_R3k6Fy_8jzYb7jJL-LnkjypTBmsyXs-xuhA@mail.gmail.com>
References: <20130319142141.5d32cae2@nehalam.linuxnetplumber.net>
	<20130319.172645.2081434694692631052.davem@davemloft.net>
	<CALnjE+ryZpcfev4xDQ8dcnrxFqXFjjxvnnxN_dU35gu_KEk86g@mail.gmail.com>
	<20130319.175612.1450380502469601673.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	jesse@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog132.obsmtp.com ([74.125.149.250]:35111 "HELO
	na3sys009aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757443Ab3CYTbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 15:31:00 -0400
Received: by mail-ve0-f200.google.com with SMTP id m1so2098633ves.7
        for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 12:30:47 -0700 (PDT)
In-Reply-To: <20130319.175612.1450380502469601673.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 19, 2013 at 2:56 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin Shelar <pshelar@nicira.com>
> Date: Tue, 19 Mar 2013 14:38:11 -0700
>
>> On Tue, Mar 19, 2013 at 2:26 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Stephen Hemminger <stephen@networkplumber.org>
>>> Date: Tue, 19 Mar 2013 14:21:41 -0700
>>>
>>>> Doesn't build with this patch alone (ie. not bisectable).
>>>>
>>>>   CC [M]  net/ipv6/ip6_gre.o
>>>> net/ipv6/ip6_gre.c:41:27: fatal error: net/ip_tunnel.h: No such file or directory
>>>> compilation terminated.
>>>
>>> Oh well, too late, it's all already in my tree.
>>
>> sorry about that.
>> I am sending update patch soon.
>
> There is nothing for you to send, what's in my tree is not changing.

I do not see these patches in net-next and now there are few conflicts
due GRE commits.
Do you want me to send updated patches against latest net-next?
