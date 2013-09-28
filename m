From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] b44: add support for Byte Queue Limits
Date: Sat, 28 Sep 2013 15:14:36 -0700
Message-ID: <1380406476.3596.5.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380403338-12056-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, zambrano@broadcom.com, netdev@vger.kernel.org
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:35956 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755076Ab3I1WOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 18:14:38 -0400
Received: by mail-pd0-f173.google.com with SMTP id p10so4037976pdj.18
        for <netdev@vger.kernel.org>; Sat, 28 Sep 2013 15:14:37 -0700 (PDT)
In-Reply-To: <1380403338-12056-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-09-28 at 23:22 +0200, Hauke Mehrtens wrote:
> This makes it possible to use some more advanced queuing
> techniques with this driver.
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> ---
>  drivers/net/ethernet/broadcom/b44.c |   10 ++++++++++
>  1 file changed, 10 insertions(+)

Reviewed-by: Eric Dumazet <edumazet@google.com>
