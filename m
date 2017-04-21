From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v6 1/3] net sched actions: User proper root
 attribute table for actions
Date: Fri, 21 Apr 2017 10:50:15 -0400
Message-ID: <011609c6-bb20-6756-8e42-624aeaf9b203@mojatatu.com>
References: <1492772132-16559-1-git-send-email-jhs@emojatatu.com>
 <1492772132-16559-2-git-send-email-jhs@emojatatu.com>
 <20170421130809.GB1874@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34275 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161525AbdDUOuY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 10:50:24 -0400
Received: by mail-io0-f194.google.com with SMTP id h41so31145348ioi.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 07:50:23 -0700 (PDT)
In-Reply-To: <20170421130809.GB1874@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-21 09:08 AM, Jiri Pirko wrote:
> subj: s/user/use/
>
>
> Fri, Apr 21, 2017 at 12:55:30PM CEST, jhs@mojatatu.com wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>> Bug fix for an issue which has been around for about a decade.
>> We got away with it because the enumeration was larger than needed.
>>
>> Fixes commit 7ba699c604ab ("[NET_SCHED]: Convert actions from rtnetlink to new netlink API")
>
> ^^^^^^^^^^^^^^^^^ this is incorrect format.
>
>>
>> Thanks to Jiri Pirko for spotting it.
>
> Suggested-by: Jiri Pirko <jiri@mellanox.com>
>
>

Will fix in the next update.

cheers,
jamal
