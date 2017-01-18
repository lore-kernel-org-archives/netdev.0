From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: Add support for user
 cookies
Date: Wed, 18 Jan 2017 06:00:46 -0500
Message-ID: <29f63a2f-f08f-f7cd-f81a-eec525355399@mojatatu.com>
References: <1484651509-27500-1-git-send-email-jhs@emojatatu.com>
 <1484651509-27500-2-git-send-email-jhs@emojatatu.com>
 <587E2747.9000207@iogearbox.net>
 <bead2dc5-87a2-2fca-d50d-871f28be1d5b@mojatatu.com>
 <587E4D16.8030708@iogearbox.net> <20170117170501.GE1807@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@mellanox.com,
        paulb@mellanox.com, john.fastabend@gmail.com,
        simon.horman@netronome.com, mrv@mojatatu.com, hadarh@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, xiyou.wangcong@gmail.com
To: Jiri Pirko <jiri@resnulli.us>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:33454 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753038AbdARLJA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 06:09:00 -0500
Received: by mail-qk0-f193.google.com with SMTP id 11so1281833qkl.0
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 03:08:59 -0800 (PST)
In-Reply-To: <20170117170501.GE1807@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-17 12:05 PM, Jiri Pirko wrote:
> Tue, Jan 17, 2017 at 05:57:58PM CET, daniel@iogearbox.net wrote:

>> Given this cookie is just used for correlation in user space anyway
>> and not processed any further by the kernel, I think we can well
>> handle these very few spots, so would be better if the code is more
>> maintainable instead.
>
> I agree with Daniel. His naming change suggestions make sense.
>
> In fact, Jamal, now I know why there are names like this all over TC :)
>

Jiri, how about Hungarian Notation with that? ;->
I will change the name but it is getting towards proving
Parkinson's law of Triviality.

cheers,
jamal
