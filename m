From: Tomas Winkler <tomasw@gmail.com>
Subject: Re: [PATCH 38/75] iwmc3200top: declare MODULE_FIRMWARE
Date: Sat, 7 Nov 2009 23:56:41 +0200
Message-ID: <1ba2fa240911071356r4e5faad9wb53bd3e51f6703ff@mail.gmail.com>
References: <1257630800.15927.436.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:43703 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753580AbZKGWD1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2009 17:03:27 -0500
Received: by bwz27 with SMTP id 27so2300195bwz.21
        for <netdev@vger.kernel.org>; Sat, 07 Nov 2009 14:03:31 -0800 (PST)
In-Reply-To: <1257630800.15927.436.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 7, 2009 at 11:53 PM, Ben Hutchings <ben@decadent.org.uk> wr=
ote:
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> =C2=A0drivers/misc/iwmc3200top/fw-download.c | =C2=A0 =C2=A02 ++
> =C2=A01 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/misc/iwmc3200top/fw-download.c b/drivers/misc/iw=
mc3200top/fw-download.c
> index 33cb693..2817618 100644
> --- a/drivers/misc/iwmc3200top/fw-download.c
> +++ b/drivers/misc/iwmc3200top/fw-download.c
> @@ -357,3 +357,5 @@ exit:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> =C2=A0}
> +
> +MODULE_FIRMWARE("iwmc3200top.1.fw");

Thanks but I have this one already in the pipe but actually grouped
with all module declarations in the main.c
Thanks
Tomas
