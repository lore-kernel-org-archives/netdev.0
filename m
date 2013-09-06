From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] net: add documentation for BQL helpers
Date: Fri, 06 Sep 2013 09:09:46 -0700
Message-ID: <1378483786.31445.28.camel@edumazet-glaptop>
References: <1378465119-1894-1-git-send-email-f.fainelli@gmail.com>
	 <1378483080-31632-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:64817 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756836Ab3IFQJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 12:09:48 -0400
Received: by mail-pd0-f172.google.com with SMTP id z10so3441929pdj.3
        for <netdev@vger.kernel.org>; Fri, 06 Sep 2013 09:09:48 -0700 (PDT)
In-Reply-To: <1378483080-31632-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-09-06 at 16:58 +0100, Florian Fainelli wrote:
> Provide a kernel-doc comment documentation for the BQL helpers:
> - netdev_sent_queue
> - netdev_completed_queue
> - netdev_reset_queue
> 
> Similarly to how it is done for the other functions, the documentation
> only covers the function operating on struct net_device and not struct
> netdev_queue.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Change since v1:
> - incorporate suggestsions from Eric Dumazet and just specify the exact
>   match for netdev_sent_queue/netdev_completed_queue

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks
