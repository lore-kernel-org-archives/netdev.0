From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net 0/5] net_sched: tc action fixes and updates
Date: Fri, 12 Aug 2016 07:12:55 -0400
Message-ID: <53a7ddda-6b53-d083-93b3-0dfb0d7a0911@mojatatu.com>
References: <1470689209-17682-1-git-send-email-xiyou.wangcong@gmail.com>
 <a79fc4fd-69aa-0af6-bb2d-7729610f97e4@mojatatu.com>
 <CAM_iQpUCqzytG662vBd4D0Zx09CWA9a1VuZerTatMMhdy42jBA@mail.gmail.com>
 <62bb1c25-2967-dedc-89ac-01632d0e090d@mojatatu.com>
 <CAM_iQpXW4Rt4=H89ZdK2BwEmK2FBHownmXEoeAWjBsQW5mLxRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:33768 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356AbcHLLNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 07:13:04 -0400
Received: by mail-qk0-f174.google.com with SMTP id t7so21811789qkh.0
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 04:13:03 -0700 (PDT)
In-Reply-To: <CAM_iQpXW4Rt4=H89ZdK2BwEmK2FBHownmXEoeAWjBsQW5mLxRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-11 08:08 PM, Cong Wang wrote:
> On Thu, Aug 11, 2016 at 9:20 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 16-08-10 04:06 PM, Cong Wang wrote:

>> Ok, I did a quick look at your patch - I still see you converting
>> from array to list. I mean get tcf_exts_exec() to take an array
>> and walk it. That will restore the perf numbers to the same level.
>
>
> Makes sense! I just did this change as you suggest.

Ok, took look at it. Looks promising! Thanks Cong. I will test
and get back to you (sorry, likely by end of day)

cheers,
jamal
