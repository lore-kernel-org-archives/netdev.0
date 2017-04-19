From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v4 2/2] net sched actions: add time filter for
 action dumping
Date: Wed, 19 Apr 2017 17:55:48 +0200
Message-ID: <20170419155548.GI3357@nanopsycho.orion>
References: <1492603050-9318-1-git-send-email-jhs@emojatatu.com>
 <1492603050-9318-2-git-send-email-jhs@emojatatu.com>
 <20170419125336.GC3357@nanopsycho.orion>
 <f1704aae-af9d-75eb-47f7-64950f2b841b@mojatatu.com>
 <20170419141419.GF3357@nanopsycho.orion>
 <c05c6e23-2008-2860-4aa9-e318a20db4d6@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35266 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937740AbdDSPzv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 11:55:51 -0400
Received: by mail-wr0-f196.google.com with SMTP id l44so3785206wrc.2
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 08:55:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <c05c6e23-2008-2860-4aa9-e318a20db4d6@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 19, 2017 at 05:47:21PM CEST, jhs@mojatatu.com wrote:
>On 17-04-19 10:14 AM, Jiri Pirko wrote:
>> Wed, Apr 19, 2017 at 03:11:26PM CEST, jhs@mojatatu.com wrote:
>
>> So it is hard coded. That confused me. I believe it would be good to
>> provide actual tc patch that does the proper changes and include the
>> example of that usage in the description - instead of "hackedtc"
>> 
>
>Yes, the user sets it. I can make the diff available next time.
>I didnt want to go on a discussion how to pass the command line
>parameter in tc.

I think it is very good to send kernel and userspace part together.
Makes people to easily figure out what is going on and helps with
review.


>
>> TIME_DELTA?
>> 
>
>sure.
>
>Let me wait more comments then I will push the new update
>by tommorow.
>
>cheers,
>jamal
