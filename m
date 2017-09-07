From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: latest netdev net-next kernel panic
Date: Thu, 07 Sep 2017 14:39:48 -0700
Message-ID: <1504820388.15310.71.camel@edumazet-glaptop3.roam.corp.google.com>
References: <9f4c89c9-1a1b-39ec-6d8c-2c9e4c15911a@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:35663 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755840AbdIGVju (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 17:39:50 -0400
Received: by mail-pg0-f54.google.com with SMTP id 188so1612848pgb.2
        for <netdev@vger.kernel.org>; Thu, 07 Sep 2017 14:39:50 -0700 (PDT)
In-Reply-To: <9f4c89c9-1a1b-39ec-6d8c-2c9e4c15911a@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-09-07 at 23:30 +0200, Paweł Staszewski wrote:
> I want to mention also here cause last trace for RIP was dst_dev_put
> 
> https://bugzilla.kernel.org/attachment.cgi?id=258259

Can you provide a bit more context ?

Thanks !
