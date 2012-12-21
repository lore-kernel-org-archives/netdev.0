From: Zhiyun Qian <zhiyunq@umich.edu>
Subject: Re: TCP sequence number inference attack on Linux
Date: Fri, 21 Dec 2012 14:13:12 -0500
Message-ID: <CALvgte-=v=bRnQ2HPDxyqxBOjD6DXp_BUySW6Hm7h+81M+RYMA@mail.gmail.com>
References: <CALvgte86miv450KnOcFRR-oEm_f=qRXarDfQkyU7T3OLqq816A@mail.gmail.com>
	<1356114663.21834.7697.camel@edumazet-glaptop>
	<1356115931.21834.7745.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:46438 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085Ab2LUTUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 14:20:20 -0500
Received: by mail-wi0-f182.google.com with SMTP id hn14so2978398wib.9
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 11:20:18 -0800 (PST)
In-Reply-To: <1356115931.21834.7745.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That seems like a good idea. I am not sure how it is implemented
though. Is it a new feature of Linux? Would you mind sending some
pointers for this?

Thanks.
-Zhiyun

On Fri, Dec 21, 2012 at 1:52 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2012-12-21 at 10:31 -0800, Eric Dumazet wrote:
>
>> I believe RFC 5961 was implemented in recent linux versions.
>>
>> Is the described vulnerability still present ?
>>
>
> By the way, I believe Chrome browser uses private network namespaces,
> and statistics are per network namespace, so it should be safe.
>
>
>
