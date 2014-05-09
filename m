From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net: rename local_df to ignore_df
Date: Thu, 8 May 2014 21:40:39 -0700
Message-ID: <CAM_iQpXzYsHc7i3hx5UVONbQA6+z3S5M=gq5o0FhQq+7FD+RPw@mail.gmail.com>
References: <1399246758-29795-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140507.153014.491918803207368640.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
	Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:65310 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbaEIEkj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 00:40:39 -0400
Received: by mail-oa0-f45.google.com with SMTP id l6so4243013oag.4
        for <netdev@vger.kernel.org>; Thu, 08 May 2014 21:40:39 -0700 (PDT)
In-Reply-To: <20140507.153014.491918803207368640.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 7, 2014 at 12:30 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Sun,  4 May 2014 16:39:18 -0700
>
>> As suggested by several people, rename local_df to ignore_df,
>> since it means "ignore df bit if it is set".
>>
>> Cc: Maciej =C5=BBenczykowski <maze@google.com>
>> Cc: Florian Westphal <fw@strlen.de>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
> I'll apply this the next time I merge net into net-next in order to d=
eal
> with the conflict with Florian's bug fixes more easily.
>

Sounds good to me.

Thanks.
