From: tingwei liu <tingw.liu@gmail.com>
Subject: Re: [PATCH 1/1]core:Change a wrong explain about dev_get_by_name
Date: Sat, 23 Mar 2013 09:33:35 +0800
Message-ID: <CA+qZnSQABuJfJDQRi5n+HQqNcRCgYDyZy_Fa0EY-s=_CcNfP9g@mail.gmail.com>
References: <CA+qZnSSMfbeGsThYe-=tK-kZ3h1GEKDGkNom+07-hRSqgLUUWg@mail.gmail.com>
	<1363793549.3333.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f171.google.com ([209.85.210.171]:37745 "EHLO
	mail-ia0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422670Ab3CWBdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 21:33:36 -0400
Received: by mail-ia0-f171.google.com with SMTP id z13so4099082iaz.30
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 18:33:36 -0700 (PDT)
In-Reply-To: <1363793549.3333.12.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 20, 2013 at 11:32 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2013-03-20 at 17:33 +0800, tingwei liu wrote:
>> From 5d787e8c3725efa6af3036eeb52aba1905c70de9 Mon Sep 17 00:00:00 2001
>> From: root <root@linux-19.site>
>> Date: Wed, 20 Mar 2013 17:39:59 +0800
>> Subject: [PATCH] Change a wrong explain about dev_get_by_name
>>
>
> No changelog ? This patch really needs a changelog.
>
How to get the lastest commit about this comment?
Thanks a lot.
> I have no idea why we should document this function being not safe in
> irq context.
>
> Most part of networking stack is non safe in hard irq context.
>
> Should we add a comment in front of all possible entry points ?
>
>
>
