From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net] dccp/tcp: fix ireq->opt races
Date: Fri, 20 Oct 2017 08:58:57 -0700
Message-ID: <1508515137.30291.8.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1508451889.30291.4.camel@edumazet-glaptop3.roam.corp.google.com>
         <20171020.070458.2242397039979446788.davem@davemloft.net>
         <20171020.071831.180922551241959965.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:46418 "EHLO
        mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752009AbdJTP7A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 11:59:00 -0400
Received: by mail-io0-f178.google.com with SMTP id 101so13715465ioj.3
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 08:59:00 -0700 (PDT)
In-Reply-To: <20171020.071831.180922551241959965.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-10-20 at 07:18 +0100, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Fri, 20 Oct 2017 07:04:58 +0100 (WEST)
> 
> > Much better, applied and queued up for -stable.
> 
> I take that back.
> 
> Please build test your changes more thoroughly.

Arg, sorry for wasting your time, I will send a v4.
