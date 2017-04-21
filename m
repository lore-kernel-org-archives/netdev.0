From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] Replace 2 jiffies with sysctl
 netdev_budget_usecs to enable softirq tuning
Date: Fri, 21 Apr 2017 13:07:27 -0700
Message-ID: <1492805247.6453.33.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1492619830-7561-1-git-send-email-tedheadster@gmail.com>
         <20170421.132245.1207278487695293623.davem@davemloft.net>
         <1492804622.6453.32.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170421.160052.848351578908155648.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: tedheadster@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34733 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425904AbdDUUHa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 16:07:30 -0400
Received: by mail-io0-f193.google.com with SMTP id h41so34112485ioi.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 13:07:30 -0700 (PDT)
In-Reply-To: <20170421.160052.848351578908155648.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-04-21 at 16:00 -0400, David Miller wrote:

> That's true, I'll kill this.
> 

Thanks !
