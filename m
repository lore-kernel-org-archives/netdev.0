From: tingwei liu <tingw.liu@gmail.com>
Subject: Re: [PATCH net-next] tcp:elapsed variable calculated twice while
 keepalive working
Date: Tue, 6 Aug 2013 20:29:14 +0800
Message-ID: <CA+qZnSRs8CmW6MTqyvkpgNuR=v37yDf1WzevhOJSCKO1mGXWbA@mail.gmail.com>
References: <1375790724-18834-1-git-send-email-tingw.liu@gmail.com>
	<1375791792.4457.99.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:64678 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754992Ab3HFM3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 08:29:15 -0400
Received: by mail-pd0-f177.google.com with SMTP id u10so275238pdi.22
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 05:29:14 -0700 (PDT)
In-Reply-To: <1375791792.4457.99.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 6, 2013 at 8:23 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2013-08-06 at 20:05 +0800, Tingwei Liu wrote:
>> ---
>>  net/ipv4/tcp_timer.c |    6 +++---
>>  1 files changed, 3 insertions(+), 3 deletions(-)
>
> I suggest reading Documentation/SubmittingPatches, because you forgot
> the "Signed-off-by:" tag, and you did the same on your last patch
> submission.
Thanks very much! I will resend the patch in a few minutes.
>
>
>
>
