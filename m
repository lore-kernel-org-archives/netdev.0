From: Hao Zhang <hao5781286@gmail.com>
Subject: Re: [PATCH] net: ethernet: sfc: There is a typo, modify curent to current.
Date: Fri, 29 Sep 2017 19:51:44 +0800
Message-ID: <CAJeuY79-g7z2-cvjGJ9bGsSeFvMQfbD19qPB35cU6qYFy5ENig@mail.gmail.com>
References: <20170929101937.GA8963@arx-kt>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: davem@davemloft.net, bkenward@solarflare.com, ecree@solarflare.com,
        netdev@vger.kernel.org, linux-net-drivers@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f195.google.com ([209.85.217.195]:36890 "EHLO
        mail-ua0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752162AbdI2Lvq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 07:51:46 -0400
Received: by mail-ua0-f195.google.com with SMTP id q29so278641uaf.4
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 04:51:46 -0700 (PDT)
In-Reply-To: <20170929101937.GA8963@arx-kt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resend to maintainer.



Regards :)

2017-09-29 18:19 GMT+08:00 Hao Zhang <hao5781286@gmail.com>:
> There is a typo, fix it by modify curent to current.
>
> Signed-off-by: Hao Zhang <hao5781286@gmail.com>
> ---
>  drivers/net/ethernet/sfc/mcdi_pcol.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/sfc/mcdi_pcol.h b/drivers/net/ethernet/sfc/mcdi_pcol.h
> index 91fb54f..8bfc8d4 100644
> --- a/drivers/net/ethernet/sfc/mcdi_pcol.h
> +++ b/drivers/net/ethernet/sfc/mcdi_pcol.h
> @@ -11505,7 +11505,7 @@
>
>  /***********************************/
>  /* MC_CMD_GET_SNAPSHOT_LENGTH
> - * Obtain the curent range of allowable values for the SNAPSHOT_LENGTH
> + * Obtain the current range of allowable values for the SNAPSHOT_LENGTH
>   * parameter to MC_CMD_INIT_RXQ.
>   */
>  #define MC_CMD_GET_SNAPSHOT_LENGTH 0x101
> --
> 2.7.4
>
