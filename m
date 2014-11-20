From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] bonding: clear header_ops when last slave detached (v2)
Date: Thu, 20 Nov 2014 14:13:16 -0800
Message-ID: <CAHA+R7P9XhGQZXFy6frxOyZJ4rX_MdVgY3kAPE1_wDNcvYd_yA@mail.gmail.com>
References: <1416374292-10993-1-git-send-email-wen.gang.wang@oracle.com>
	<1416375565.14060.43.camel@edumazet-glaptop2.roam.corp.google.com>
	<546C4022.5010509@oracle.com>
	<CAHA+R7OyA_V149bpE8qUgG9epU-5UG8cf=zOgh5ZXVB3ZFZHUw@mail.gmail.com>
	<1416465685.8629.15.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7PKRbBNwfUWRAsVHQreKsGXBc8CHorZRuyCfvwL4O=y+g@mail.gmail.com>
	<1416516104.8629.39.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7Me4zPdGpeQVHFLLGVq=4cVar09jQFyjA81nxF_Fmuppw@mail.gmail.com>
	<1416521035.8629.49.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wengang <wen.gang.wang@oracle.com>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:41228 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756409AbaKTWNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 17:13:17 -0500
Received: by mail-wi0-f171.google.com with SMTP id bs8so10184947wib.16
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 14:13:16 -0800 (PST)
In-Reply-To: <1416521035.8629.49.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 20, 2014 at 2:03 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Provide a patch, please.
>
>

Don't blame me.

I want to provide a real fix, you want a minimum fix for stable.
We agree that we disagree on this point, right? What's
more, according to your rule, I should yield to you when I
touch something you want to touch.

Also, no one seems to care about my previous question:
why only bonding has the problem?
