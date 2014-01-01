From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: Re: [PATCH 0/2] tun: add the RFS support
Date: Wed, 1 Jan 2014 14:44:10 +0800
Message-ID: <CAEH94LiYzvHFy-5oMOnkj8KJAZXUnY+wcrkFAMnrjkOM4Sb6hA@mail.gmail.com>
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
Received: from mail-oa0-f53.google.com ([209.85.219.53]:56334 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbaAAGoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 01:44:10 -0500
Received: by mail-oa0-f53.google.com with SMTP id m1so13784419oag.40
        for <netdev@vger.kernel.org>; Tue, 31 Dec 2013 22:44:10 -0800 (PST)
In-Reply-To: <CA+mtBx8b_D+JQaphS4LCbAVKRWE5Tz1-P_eVxJJdG-FbMdWPdw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 1, 2014 at 6:33 AM, Tom Herbert <therbert@google.com> wrote:
> Zhi,
>
> Thanks for following up on these patches. It would still be nice to
> have performance numbers to show the impact. These will be helpful for
> the next task of integrating RFS into virtio-net.
Will try to do them after holiday, if you have any special test cases,
please let me know, thanks.

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
