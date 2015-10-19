From: Gao feng <omarapazanadi@gmail.com>
Subject: Re: [PATCH v3] vsock: fix missing cleanup when misc_register failed
Date: Mon, 19 Oct 2015 10:06:25 +0800
Message-ID: <CABxRWoOM7fRGC0=pSo1PoQdeF1FVcsReKSgSQysqeXY_+sLF6g@mail.gmail.com>
References: <1445182556-24073-1-git-send-email-omarapazanadi@gmail.com>
	<20151018.185013.1508341298626923808.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35201 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752035AbbJSCG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2015 22:06:27 -0400
Received: by wicll6 with SMTP id ll6so75565076wic.0
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2015 19:06:25 -0700 (PDT)
In-Reply-To: <20151018.185013.1508341298626923808.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm sorry too, fell free to ignore my patch, Thanks.

2015-10-19 9:50 GMT+08:00 David Miller <davem@davemloft.net>:
> From: Gao feng <omarapazanadi@gmail.com>
> Date: Sun, 18 Oct 2015 23:35:56 +0800
>
>> reset transport and unlock if misc_register failed.
>>
>> Signed-off-by: Gao feng <omarapazanadi@gmail.com>
>
> It's extremely disappointing that it took you three revisions
> just to put together a submission that actually compiles.
>
> That shows me that you put a very low amount of care into your
> submission, and if you don't care about your change why should I?
