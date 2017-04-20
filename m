From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v5 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Thu, 20 Apr 2017 11:08:20 -0400
Message-ID: <7e9dbb08-fb80-aee6-a0d0-dce56cbfd7c3@mojatatu.com>
References: <1492693582-26810-1-git-send-email-jhs@emojatatu.com>
 <1492693582-26810-2-git-send-email-jhs@emojatatu.com>
 <20170420135915.GE1886@nanopsycho.orion>
 <67dc8e10-b0df-c0c5-7c46-ac4147c1c797@mojatatu.com>
 <20170420143313.GA19004@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:36632 "EHLO
        mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S969044AbdDTPJS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 11:09:18 -0400
Received: by mail-io0-f171.google.com with SMTP id o22so80743975iod.3
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 08:09:18 -0700 (PDT)
In-Reply-To: <20170420143313.GA19004@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-20 10:33 AM, Jiri Pirko wrote:
> Thu, Apr 20, 2017 at 04:25:11PM CEST, jhs@mojatatu.com wrote:

>>> TCAA stands for "traffic control action action". I don't get it :(
>>
>> TC Action Attributes == TCAA.
>>
>>> Prefix still sounds wrong to me, sorry :/
>>> Should be:
>>> TCA_SOMETHING_*
>>>
>>
>> TCA_ATTR_XXX ?
>
> Of course it is an attribute. No need to have "attr" in the name. No
> other enum has it. Does not make sense.
>
> The name should contain the group name. What group this enum defines?
>

It defines tc root level Action attributes.
Would TCRLAA_XXX be more exciting? ;->

cheers,
jamal
