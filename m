From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] strp: Stream parser for messages
Date: Mon, 01 Aug 2016 13:46:26 -0700 (PDT)
Message-ID: <20160801.134626.597358167256129014.davem@davemloft.net>
References: <1470069200-3279258-1-git-send-email-tom@herbertland.com>
	<20160801.132722.1134084069187483498.davem@davemloft.net>
	<CALx6S37EMYLXW28SETev-hJTFS=q_r-qPSzJeuyTM8Wj7yjBsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54860 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752180AbcHAU4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2016 16:56:31 -0400
In-Reply-To: <CALx6S37EMYLXW28SETev-hJTFS=q_r-qPSzJeuyTM8Wj7yjBsw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 1 Aug 2016 13:38:46 -0700

> On Mon, Aug 1, 2016 at 1:27 PM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <tom@herbertland.com>
>> Date: Mon, 1 Aug 2016 09:33:17 -0700
>>
>>>   - Remove GPL module license from strparser.c
>>
>> Why?
> 
> It looked more consistent with other modules. Is GPL module license
> preferred then?

Yes.

Since this is a facility which is largely unique to the Linux kernel,
things linking to these symbols are almost certainly derived works.
