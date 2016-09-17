From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] MAINTAINERS: Gary Zambrano's email is bouncing
Date: Sat, 17 Sep 2016 16:17:39 -0700
Message-ID: <CAGVrzcaswHEjEvBygXbDcgUPaAmP=t9RHY8mVv4tVOgK7N9ARw@mail.gmail.com>
References: <1474151235-16558-1-git-send-email-f.fainelli@gmail.com> <1474152709.1954.8.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        bcm-kernel-feedback-list <bcm-kernel-feedback-list@broadcom.com>,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
        Hauke Mehrtens <hauke@hauke-m.de>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36765 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935318AbcIQXSU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 19:18:20 -0400
Received: by mail-io0-f196.google.com with SMTP id z135so3271378ioe.3
        for <netdev@vger.kernel.org>; Sat, 17 Sep 2016 16:18:20 -0700 (PDT)
In-Reply-To: <1474152709.1954.8.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-09-17 15:51 GMT-07:00 Joe Perches <joe@perches.com>:
> On Sat, 2016-09-17 at 15:27 -0700, Florian Fainelli wrote:
>> Gary has not been with Broadcom for some time now, replace his address
>> with the internal mailing-list used for other entries.
>>
>> > Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>> Michael,
>>
>> Since this is an old driver, not sure who could step up as a maintainer
>> for b44?
> []
>> diff --git a/MAINTAINERS b/MAINTAINERS
> []
>> @@ -2500,8 +2500,8 @@ S:      Supported
>
>> F:    kernel/bpf/
>>
>>  BROADCOM B44 10/100 ETHERNET DRIVER
>> -M:   Gary Zambrano <zambrano@broadcom.com>
>>  L:   netdev@vger.kernel.org
>> +M:   bcm-kernel-feedback-list@broadcom.com
>>  S:   Supported
>>  F:   drivers/net/ethernet/broadcom/b44.*
>
> Without an actual maintainer, this should really be
> orphan and not supported.

I would like to hear from Michael before concluding that

>
> And the M: bcm-kernel-feedback-list@ should be L:

The list does not accept public subscribers, so this is the correct
entry to use.

>
> BCM4401 NICs are essentially from 2002.
>
> Does anyone really use these any longer with a
> current distribution or kernel version?

This NIC is also embedded inside BCM47xx/BCM53xx which is still
getting active support from Rafal and Hauke.
-- 
Florian
