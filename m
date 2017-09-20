From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Latest net-next from GIT panic
Date: Tue, 19 Sep 2017 20:24:30 -0700
Message-ID: <1505877870.29839.82.camel@edumazet-glaptop3.roam.corp.google.com>
References: <4745525f-18e4-7f69-fe21-8e507e407b33@itcare.pl>
         <d8bbf6c1-20a3-195c-6980-45f29e9f9278@itcare.pl>
         <2aeb7871-fe89-c714-3355-c5f48651e70c@itcare.pl>
         <15d293fa-0f53-bdca-6358-6a58d1da77af@itcare.pl>
         <65e2195b-3bd1-c0b4-b474-e07dd08f71b9@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:49702 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751000AbdITDYc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 23:24:32 -0400
Received: by mail-pf0-f180.google.com with SMTP id l188so872747pfc.6
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 20:24:32 -0700 (PDT)
In-Reply-To: <65e2195b-3bd1-c0b4-b474-e07dd08f71b9@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-09-20 at 02:06 +0200, Paweł Staszewski wrote:
> Just checked kernel 4.13.2 and same problem
> 
> Just after start all 6 bgp sessions - and kernel starts to learn routes 
> it panic.
> 
> https://bugzilla.kernel.org/attachment.cgi?id=258509
> 


Unfortunately we have not enough information from these traces.

Can you get a full stack trace ?

Alternatively, can you bisect ?

Thanks.
