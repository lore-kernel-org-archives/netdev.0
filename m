From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v5 10/10] MAINTAINERS: add entry for the Broadcom
 GENET driver
Date: Sat, 15 Feb 2014 00:37:09 +0300
Message-ID: <52FE8C85.5070008@cogentembedded.com>
References: <1392336531-28875-1-git-send-email-f.fainelli@gmail.com> <1392336531-28875-11-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, devicetree@vger.kernel.org,
	cernekee@gmail.com, mark.rutland@arm.com, romieu@fr.zoreil.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:59519 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752365AbaBNUhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 15:37:07 -0500
Received: by mail-lb0-f170.google.com with SMTP id u14so9843338lbd.1
        for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 12:37:05 -0800 (PST)
In-Reply-To: <1392336531-28875-11-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02/14/2014 03:08 AM, Florian Fainelli wrote:

> Add myself as a maintainer of the Broadcom GENET driver.

> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
[...]

> diff --git a/MAINTAINERS b/MAINTAINERS
> index 091b50e..5a7b3ec 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -1845,6 +1845,12 @@ L:	netdev@vger.kernel.org
>   S:	Supported
>   F:	drivers/net/ethernet/broadcom/b44.*
>
> +BROADCOM GENET ETHERNET DRIVER
> +M:	Florian Fainelli <f.fainelli@gmail.com>
> +L:	netdev@vger.kernel.org
> +S:	Supported
> +F:	drivers/net/ethernet/broadcom/genet/
> +

    Aren't these entries supposed to be sorted alphabetically? If so, in my 
alphabet BNX2 comes before GENET...

>   BROADCOM BNX2 GIGABIT ETHERNET DRIVER
>   M:	Michael Chan <mchan@broadcom.com>
>   L:	netdev@vger.kernel.org

PS: I'm probably wrong, the entries don't appear to be sorted on the 2nd word...

WBR, Sergei
