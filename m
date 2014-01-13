From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: Re: [PATCH 0/2] tun: add the RFS support
Date: Mon, 13 Jan 2014 21:29:45 +0800
Message-ID: <CAEH94LjdMyZ_SVf5YvzqEhPzYanFQUwLsm+e8Hp_Y5XU4_hkeA@mail.gmail.com>
References: <1387709672-21917-1-git-send-email-zwu.kernel@gmail.com>
	<20131231.133200.1111966466957616549.davem@davemloft.net>
	<CA+mtBx8b_D+JQaphS4LCbAVKRWE5Tz1-P_eVxJJdG-FbMdWPdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:59111 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812AbaAMN3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 08:29:45 -0500
Received: by mail-ob0-f170.google.com with SMTP id uy5so5751306obc.29
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 05:29:45 -0800 (PST)
In-Reply-To: <CA+mtBx8b_D+JQaphS4LCbAVKRWE5Tz1-P_eVxJJdG-FbMdWPdw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 1, 2014 at 6:33 AM, Tom Herbert <therbert@google.com> wrote:
> Zhi,
HI, Tom
>
> Thanks for following up on these patches. It would still be nice to
> have performance numbers to show the impact. These will be helpful for
> the next task of integrating RFS into virtio-net.
I don't get why RFS need to be integrated into virtio-net since
virtio-net has supported mq. Can you give some clue? thanks.

>
> Tom
>
> On Tue, Dec 31, 2013 at 10:32 AM, David Miller <davem@davemloft.net> wrote:
>> From: Zhi Yong Wu <zwu.kernel@gmail.com>
>> Date: Sun, 22 Dec 2013 18:54:30 +0800
>>
>>> Since Tom Herbert's hash related patchset was modified and got merged,
>>> his pachset about adding support for RFS on tun flows also need to get
>>> adjusted accordingly. I tried to update them, and before i will start
>>> to do some perf tests, i hope to get one correct code base, so it's time
>>> to post them out now. Any constructive comments are welcome, thanks.
>>
>> Series applied to net-next, thanks.



-- 
Regards,

Zhi Yong Wu
