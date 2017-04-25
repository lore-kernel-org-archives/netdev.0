From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 0/2] flower: add MPLS matching support
Date: Mon, 24 Apr 2017 20:58:18 -0400
Message-ID: <d54cca4b-6212-bf7d-93e2-8314177df42c@mojatatu.com>
References: <1492894367-11637-1-git-send-email-benjamin.lahaise@netronome.com>
 <20170424.143257.1003081554810761464.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcrl@kvack.org,
        Jiri Pirko <jiri@resnulli.us>
To: David Miller <davem@davemloft.net>, benjamin.lahaise@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:33232 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1171763AbdDYA6V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 20:58:21 -0400
Received: by mail-io0-f170.google.com with SMTP id k87so207503785ioi.0
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 17:58:21 -0700 (PDT)
In-Reply-To: <20170424.143257.1003081554810761464.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-24 02:32 PM, David Miller wrote:
> From: Benjamin LaHaise <benjamin.lahaise@netronome.com>

>
> Series applied, but in the future:
>
> 1) Put the "v2", "v3", whatever in the inital [PATCH xxx] bracketed
>    part of the subject line, otherwise it ends up in the GIT commit
>    message header line and that's not desired.
>
> 2) Please cut it with these double signoffs, and add an appropriate
>    entry to the email aliases file.

I know i should have spoken earlier, wanted to but got distracted - but
shouldnt the new rules have applied to this patch too? ;->

You have 3 TLVs, one of which is u8 that only allows use of 3 bits.
The other is a u32 which allows only 20 bits to be set.

cheers,
jamal
