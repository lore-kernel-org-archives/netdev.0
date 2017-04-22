From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: compile issue in latest iproute2
Date: Sat, 22 Apr 2017 16:06:57 -0400
Message-ID: <0fc4caec-6dca-69a7-65f8-2d2b1285de13@mojatatu.com>
References: <cecf76aa-2883-741e-1901-2f4850e2c188@mojatatu.com>
 <58FB7012.4080907@iogearbox.net> <58FB8272.5080306@iogearbox.net>
 <b6773e0d-a8cb-181c-4aee-15d51439675f@mojatatu.com>
 <20170422095434.730035b6@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:38404 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161511AbdDVUHD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 16:07:03 -0400
Received: by mail-it0-f42.google.com with SMTP id e132so17893380ite.1
        for <netdev@vger.kernel.org>; Sat, 22 Apr 2017 13:07:03 -0700 (PDT)
In-Reply-To: <20170422095434.730035b6@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-22 12:54 PM, Stephen Hemminger wrote:
> On Sat, 22 Apr 2017 12:43:50 -0400
> Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>
>> On 17-04-22 12:18 PM, Daniel Borkmann wrote:
>> [..]
>>>
>>> Anything I'm missing?
>>
>>
>> Let me get back to that machine (couple of hours) and try to see how i
>> created the issue.
>> Shouldve cutnpasted the error msg. Cant create it on this laptop.
>>
>> cheers,
>> jamal
>
> Current tip of iproute2 master compiles fine for me
> both with and without HAVE_ELF


Sorry - I cannot recreate it. I tried from scratch and did the patches
I was testing on and it compiled cleanly. Apologies for the alarm.

cheers,
jamal
