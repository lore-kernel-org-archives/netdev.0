From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v3 1/1] net sched actions: Add support for user
 cookies
Date: Tue, 17 Jan 2017 05:52:15 -0500
Message-ID: <bc3f6bc4-2896-0ba0-35f4-198204f9317d@mojatatu.com>
References: <1484488879-29560-1-git-send-email-jhs@emojatatu.com>
 <1484488879-29560-2-git-send-email-jhs@emojatatu.com>
 <20170116.144644.977968311370245919.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, paulb@mellanox.com,
        john.fastabend@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com, hadarh@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, xiyou.wangcong@gmail.com, daniel@iogearbox.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35793 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750826AbdAQKxG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 05:53:06 -0500
Received: by mail-qt0-f193.google.com with SMTP id f4so20571632qte.2
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 02:52:23 -0800 (PST)
In-Reply-To: <20170116.144644.977968311370245919.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-16 02:46 PM, David Miller wrote:
>
> Jamal, please don't mix coding style and real changes.
>
> Have one patch that adds the user cookies and one that cleans up the
> coding style stuff.
>
> Thanks.
>

I will separate those changes (gives me an opportunity to make
more stylistic changes).

Having said that: Is this rule really cast in stone?;->
I have seen many other people (including myself) sneak in whitespace
changes and other trivialities in a general change. I thought the rule
was to not do such things for bug fixes.

cheers,
jamal
