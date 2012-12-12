From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] uapi: add missing netconf.h to export list
Date: Wed, 12 Dec 2012 18:04:26 +0100
Message-ID: <50C8B91A.8050400@6wind.com>
References: <1355305907-7102-1-git-send-email-nicolas.dichtel@6wind.com> <20121212085852.5b840314@nehalam.linuxnetplumber.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38712 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753920Ab2LLREa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 12:04:30 -0500
Received: by mail-bk0-f46.google.com with SMTP id q16so515005bkw.19
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 09:04:29 -0800 (PST)
In-Reply-To: <20121212085852.5b840314@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/12/2012 17:58, Stephen Hemminger a =E9crit :
> Add netconf.h for use by iproute2.
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

>
> --- a/include/uapi/linux/Kbuild	2012-10-25 09:11:15.499273810 -0700
> +++ b/include/uapi/linux/Kbuild	2012-12-12 08:56:36.130263710 -0800
> @@ -258,6 +258,7 @@ header-y +=3D neighbour.h
>   header-y +=3D net.h
>   header-y +=3D net_dropmon.h
>   header-y +=3D net_tstamp.h
> +header-y +=3D netconf.h
>   header-y +=3D netdevice.h
>   header-y +=3D netfilter.h
>   header-y +=3D netfilter_arp.h
>
