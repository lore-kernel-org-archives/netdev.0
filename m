From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: Latest net-next from GIT panic
Date: Wed, 20 Sep 2017 09:58:52 +0200
Message-ID: <07bde5d4-fab6-3ef9-f586-403dadbb0a2a@itcare.pl>
References: <4745525f-18e4-7f69-fe21-8e507e407b33@itcare.pl>
 <d8bbf6c1-20a3-195c-6980-45f29e9f9278@itcare.pl>
 <2aeb7871-fe89-c714-3355-c5f48651e70c@itcare.pl>
 <15d293fa-0f53-bdca-6358-6a58d1da77af@itcare.pl>
 <65e2195b-3bd1-c0b4-b474-e07dd08f71b9@itcare.pl>
 <1505877870.29839.82.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp16.iq.pl ([86.111.242.222]:33831 "EHLO smtp16.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751510AbdITIBD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 04:01:03 -0400
In-Reply-To: <1505877870.29839.82.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi


Will try bisecting tonight



W dniu 2017-09-20 o 05:24, Eric Dumazet pisze:
> On Wed, 2017-09-20 at 02:06 +0200, Paweł Staszewski wrote:
>> Just checked kernel 4.13.2 and same problem
>>
>> Just after start all 6 bgp sessions - and kernel starts to learn routes
>> it panic.
>>
>> https://bugzilla.kernel.org/attachment.cgi?id=258509
>>
>
> Unfortunately we have not enough information from these traces.
>
> Can you get a full stack trace ?
>
> Alternatively, can you bisect ?
>
> Thanks.
>
>
>
