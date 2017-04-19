From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 2/2] net sched actions: add time filter for
 action dumping
Date: Wed, 19 Apr 2017 11:47:21 -0400
Message-ID: <c05c6e23-2008-2860-4aa9-e318a20db4d6@mojatatu.com>
References: <1492603050-9318-1-git-send-email-jhs@emojatatu.com>
 <1492603050-9318-2-git-send-email-jhs@emojatatu.com>
 <20170419125336.GC3357@nanopsycho.orion>
 <f1704aae-af9d-75eb-47f7-64950f2b841b@mojatatu.com>
 <20170419141419.GF3357@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, xiyou.wangcong@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:36406 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1765686AbdDSPrY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 11:47:24 -0400
Received: by mail-io0-f170.google.com with SMTP id o22so26561804iod.3
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 08:47:23 -0700 (PDT)
In-Reply-To: <20170419141419.GF3357@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-19 10:14 AM, Jiri Pirko wrote:
> Wed, Apr 19, 2017 at 03:11:26PM CEST, jhs@mojatatu.com wrote:

> So it is hard coded. That confused me. I believe it would be good to
> provide actual tc patch that does the proper changes and include the
> example of that usage in the description - instead of "hackedtc"
>

Yes, the user sets it. I can make the diff available next time.
I didnt want to go on a discussion how to pass the command line
parameter in tc.

> TIME_DELTA?
>

sure.

Let me wait more comments then I will push the new update
by tommorow.

cheers,
jamal
