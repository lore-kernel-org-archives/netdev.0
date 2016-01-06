From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/4] include: update kernel headers
Date: Wed, 6 Jan 2016 09:23:18 -0800
Message-ID: <20160106092318.7e82ebd1@xeon-e3>
References: <1451901486-3497-1-git-send-email-bjorn@mork.no>
	<1451901486-3497-2-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: =?UTF-8?B?QmrDuHJu?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36311 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbcAFRXL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 12:23:11 -0500
Received: by mail-pf0-f179.google.com with SMTP id 65so196988824pff.3
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 09:23:11 -0800 (PST)
In-Reply-To: <1451901486-3497-2-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  4 Jan 2016 10:58:03 +0100
Bj=C3=B8rn Mork <bjorn@mork.no> wrote:

> Import current if_link.h from net-next
>=20
> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
> ---
>  include/linux/if_link.h | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> index c9ad487d04f0..d91f2c97d946 100644
> --- a/include/linux/if_link.h
> +++ b/include/linux/if_link.h
> @@ -216,6 +216,7 @@ enum in6_addr_gen_mode {
>  	IN6_ADDR_GEN_MODE_EUI64,
>  	IN6_ADDR_GEN_MODE_NONE,
>  	IN6_ADDR_GEN_MODE_STABLE_PRIVACY,
> +	IN6_ADDR_GEN_MODE_RANDOM,
>  };
> =20
>  /* Bridge section */

I went ahead and updated all the net-next headers.
