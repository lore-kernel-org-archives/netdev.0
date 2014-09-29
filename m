From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH next] r8169: add support for Byte Queue Limits
Date: Mon, 29 Sep 2014 14:00:32 -0700
Message-ID: <1412024432.30721.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412024209-25468-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>,
	Hayes Wang <hayeswang@realtek.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:52108 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbaI2VAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 17:00:34 -0400
Received: by mail-pd0-f173.google.com with SMTP id g10so508945pdj.32
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 14:00:34 -0700 (PDT)
In-Reply-To: <1412024209-25468-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-29 at 22:56 +0200, Florian Westphal wrote:
> tested on RTL8168d/8111d.
> 
> Cc: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Hayes Wang <hayeswang@realtek.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  drivers/net/ethernet/realtek/r8169.c | 18 ++++++++++++++----
>  1 file changed, 14 insertions(+), 4 deletions(-)

Thanks Florian, this looks good to me.

Acked-by: Eric Dumazet <edumazet@google.com>
