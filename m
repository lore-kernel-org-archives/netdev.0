From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next] MAINTAINERS: add Ivan as a switchdev maintainer
Date: Thu, 2 Feb 2017 10:14:35 -0800
Message-ID: <741d06a3-989c-a081-ac68-afb95ea651a9@gmail.com>
References: <1486051504-19623-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, ivecera@redhat.com, idosch@mellanox.com,
        mlxsw@mellanox.com, jhs@mojatatu.com, roopa@cumulusnetworks.com,
        vivien.didelot@savoirfairelinux.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34174 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752076AbdBBSOi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 13:14:38 -0500
Received: by mail-pf0-f194.google.com with SMTP id y143so1976965pfb.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 10:14:38 -0800 (PST)
In-Reply-To: <1486051504-19623-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/02/2017 08:05 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Ivan will be taking care of switchdev code from now on.

I suppose that's okay, but usually we kind of like to see people having
made prior contributions to the very subsystem they are going to
maintain before acking/nacking new maintainers.

Welcome Ivan!

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  MAINTAINERS | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 300d2ec..eacacb2 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -11908,6 +11908,7 @@ F:	include/linux/swiotlb.h
>  
>  SWITCHDEV
>  M:	Jiri Pirko <jiri@resnulli.us>
> +M:	Ivan Vecera <ivecera@redhat.com>
>  L:	netdev@vger.kernel.org
>  S:	Supported
>  F:	net/switchdev/
> 


-- 
Florian
