From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next] net_sched: remove the leftover cleanup_a()
Date: Thu, 4 Aug 2016 08:10:10 -0400
Message-ID: <193309c8-c4d4-4552-69fe-8b971ac76d53@mojatatu.com>
References: <1470159046-23577-1-git-send-email-xiyou.wangcong@gmail.com>
 <d82351ba-cd1e-d5e1-0faa-94c2bcaf720a@mojatatu.com>
 <CAM_iQpVONAiDqgUQhWRbTEUkoEQQPiSUHnpo8aQ8KtGiR1zzFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:37973 "EHLO
	mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753291AbcHDMK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 08:10:58 -0400
Received: by mail-it0-f52.google.com with SMTP id j124so260785190ith.1
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2016 05:10:19 -0700 (PDT)
In-Reply-To: <CAM_iQpVONAiDqgUQhWRbTEUkoEQQPiSUHnpo8aQ8KtGiR1zzFg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-03 11:20 AM, Cong Wang wrote:
> On Wed, Aug 3, 2016 at 4:36 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> Cong,
>>
>> Improvement on the basic test as it no longer oopses, but:
>> here's a test that will oops:
>
> Make sure you test this together with the other patch I sent
> (sorry I didn't number them), the other patch also fixed an oops.
>

Ok, just included second patch - problem still there.
Try the testcase i outlined earlier.

cheers,
jamal
