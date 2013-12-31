From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 0/2] tun: add the RFS support
Date: Tue, 31 Dec 2013 14:33:11 -0800
Message-ID: <CA+mtBx8b_D+JQaphS4LCbAVKRWE5Tz1-P_eVxJJdG-FbMdWPdw@mail.gmail.com>
References: <1387709672-21917-1-git-send-email-zwu.kernel@gmail.com>
	<20131231.133200.1111966466957616549.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Zhi Yong Wu <zwu.kernel@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:60507 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756481Ab3LaWdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 17:33:14 -0500
Received: by mail-ig0-f177.google.com with SMTP id uy17so30733387igb.4
        for <netdev@vger.kernel.org>; Tue, 31 Dec 2013 14:33:12 -0800 (PST)
In-Reply-To: <20131231.133200.1111966466957616549.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zhi,

Thanks for following up on these patches. It would still be nice to
have performance numbers to show the impact. These will be helpful for
the next task of integrating RFS into virtio-net.

Tom

On Tue, Dec 31, 2013 at 10:32 AM, David Miller <davem@davemloft.net> wrote:
> From: Zhi Yong Wu <zwu.kernel@gmail.com>
> Date: Sun, 22 Dec 2013 18:54:30 +0800
>
>> Since Tom Herbert's hash related patchset was modified and got merged,
>> his pachset about adding support for RFS on tun flows also need to get
>> adjusted accordingly. I tried to update them, and before i will start
>> to do some perf tests, i hope to get one correct code base, so it's time
>> to post them out now. Any constructive comments are welcome, thanks.
>
> Series applied to net-next, thanks.
