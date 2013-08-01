From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: check net.core.somaxconn sysctl values
Date: Thu, 01 Aug 2013 14:18:36 -0700 (PDT)
Message-ID: <20130801.141836.1104130035137318887.davem@davemloft.net>
References: <51F917CF.7010905@yandex-team.ru>
	<20130731.171019.1991802407661623893.davem@davemloft.net>
	<51FA2490.4020905@yandex-team.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, raise.sail@gmail.com,
	ebiederm@xmission.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: klamm@yandex-team.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51FA2490.4020905@yandex-team.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roman Gushchin <klamm@yandex-team.ru>
Date: Thu, 01 Aug 2013 13:04:16 +0400

> On 01.08.2013 04:10, David Miller wrote:
>> From: Roman Gushchin <klamm@yandex-team.ru>
>> Date: Wed, 31 Jul 2013 17:57:35 +0400
>>
>>> ---
>>>   net/core/sysctl_net_core.c | 6 +++++-
>>>   1 file changed, 5 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
>>> index cfdb46a..2ff093b 100644
>>> --- a/net/core/sysctl_net_core.c
>>> +++ b/net/core/sysctl_net_core.c
>>> @@ -20,7 +20,9 @@
>>
>> This patch is against old sources, please respin it against the
>> current
>> tree.
>>
>> Thanks.
>>
> 
> net: check net.core.somaxconn sysctl values

Still doesn't apply, and it's because your email client has corrupted
the patch.

Please read Documentation/email-clients.txt to learn how to fix this
problem, and then send a test patch to yourself.

Only when you can successfully apply the test patch you send to
yourself should you repost your patch here.

Thanks.
