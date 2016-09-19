From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net] MAINTAINERS: Gary Zambrano's email is bouncing
Date: Mon, 19 Sep 2016 13:03:19 -0700
Message-ID: <CACKFLinPusABwo3N=+tKLNRqEPEv6JPfZPR4=Df31MXNFZsmmw@mail.gmail.com>
References: <1474151235-16558-1-git-send-email-f.fainelli@gmail.com>
 <1474152709.1954.8.camel@perches.com> <CAGVrzcaswHEjEvBygXbDcgUPaAmP=t9RHY8mVv4tVOgK7N9ARw@mail.gmail.com>
 <CACKFLi=io5VjP+L+RVVef3FwmFt77aVFrJ+v8-4FyupNL_752w@mail.gmail.com> <ceeadf96-6ec8-1931-e43c-1d992ce03b86@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joe Perches <joe@perches.com>, netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        bcm-kernel-feedback-list <bcm-kernel-feedback-list@broadcom.com>,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
        Hauke Mehrtens <hauke@hauke-m.de>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:34804 "EHLO
        mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751543AbcISUDV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 16:03:21 -0400
Received: by mail-oi0-f45.google.com with SMTP id a62so77585165oib.1
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 13:03:21 -0700 (PDT)
In-Reply-To: <ceeadf96-6ec8-1931-e43c-1d992ce03b86@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 19, 2016 at 12:54 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 09/17/2016 04:39 PM, Michael Chan wrote:
>> On Sat, Sep 17, 2016 at 4:17 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>> 2016-09-17 15:51 GMT-07:00 Joe Perches <joe@perches.com>:
>>>> On Sat, 2016-09-17 at 15:27 -0700, Florian Fainelli wrote:
>>>>> Gary has not been with Broadcom for some time now, replace his address
>>>>> with the internal mailing-list used for other entries.
>>>>>
>>>>>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>>>>> ---
>>>>> Michael,
>>>>>
>>>>> Since this is an old driver, not sure who could step up as a maintainer
>>>>> for b44?
>>>> []
>>>>> diff --git a/MAINTAINERS b/MAINTAINERS
>>>> []
>>>>> @@ -2500,8 +2500,8 @@ S:      Supported
>>>>
>>>>> F:    kernel/bpf/
>>>>>
>>>>>  BROADCOM B44 10/100 ETHERNET DRIVER
>>>>> -M:   Gary Zambrano <zambrano@broadcom.com>
>>>>>  L:   netdev@vger.kernel.org
>>>>> +M:   bcm-kernel-feedback-list@broadcom.com
>>>>>  S:   Supported
>>>>>  F:   drivers/net/ethernet/broadcom/b44.*
>>>>
>>>> Without an actual maintainer, this should really be
>>>> orphan and not supported.
>>>
>>> I would like to hear from Michael before concluding that
>>>
>>
>> I have worked on this NIC more than 10 years ago.  Last time I
>> checked, I don't have this NIC anymore after moving offices several
>> times.
>>
>> I don't mind being the maintainer, if no one else more suitable and
>> have access to hardware wants to do it.
>
> Should I resubmit with your name as a maintainer or do you want to do it?

I will submit the patch in a day or 2.  Unless of course someone wants
to be the maintainer instead.
