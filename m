From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 05/07] via-velocity: Support for byte queue
 limits
Date: Mon, 21 Oct 2013 17:28:54 +0400
Message-ID: <52652C16.7010506@cogentembedded.com>
References: <1382292803-18875-1-git-send-email-milky-kernel@mcmilk.de> <1382292803-18875-6-git-send-email-milky-kernel@mcmilk.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Tino Reichardt <milky-kernel@mcmilk.de>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:64993 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752521Ab3JUN25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 09:28:57 -0400
Received: by mail-la0-f41.google.com with SMTP id el20so2698649lab.14
        for <netdev@vger.kernel.org>; Mon, 21 Oct 2013 06:28:56 -0700 (PDT)
In-Reply-To: <1382292803-18875-6-git-send-email-milky-kernel@mcmilk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/20/2013 10:13 PM, Tino Reichardt wrote:

> Changes to via-velocity driver to use byte queue limits.


> Signed-off-by: Tino Reichardt <milky-kernel@mcmilk.de>

> ---
>   drivers/net/ethernet/via/via-velocity.c | 18 ++++++++++++++++++
>   1 file changed, 18 insertions(+)

> diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
> index d022bf9..b084404 100644
> --- a/drivers/net/ethernet/via/via-velocity.c
> +++ b/drivers/net/ethernet/via/via-velocity.c
> @@ -1,3 +1,4 @@
> +

    Spurious newline, I guess.

>   /*
>    * This code is derived from the VIA reference driver (copyright message
>    * below) provided to Red Hat by VIA Networking Technologies, Inc. for

WBR, Sergei
