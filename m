From: Kevin Cernekee <cernekee@gmail.com>
Subject: Re: [PATCH 1/3] bcm63xx_enet: use managed io memory allocations
Date: Sun, 10 Mar 2013 12:59:38 -0700
Message-ID: <CAJiQ=7Cz0e2q61X7gsnistP7BB2wv=U-QFoFWGZ+WZgnfzHz0A@mail.gmail.com>
References: <1362923869-21346-1-git-send-email-jogo@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Maxime Bizon <mbizon@freebox.fr>,
	Florian Fainelli <florian@openwrt.org>
To: Jonas Gorski <jogo@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:53988 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753224Ab3CJT7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 15:59:39 -0400
Received: by mail-pb0-f47.google.com with SMTP id rp2so2976383pbb.34
        for <netdev@vger.kernel.org>; Sun, 10 Mar 2013 12:59:38 -0700 (PDT)
In-Reply-To: <1362923869-21346-1-git-send-email-jogo@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 10, 2013 at 6:57 AM, Jonas Gorski <jogo@openwrt.org> wrote:
> Signed-off-by: Jonas Gorski <jogo@openwrt.org>
> ---
>  drivers/net/ethernet/broadcom/bcm63xx_enet.c |   43 +++++---------------------
>  1 file changed, 7 insertions(+), 36 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c

For the whole series:

Acked-by: Kevin Cernekee <cernekee@gmail.com>
