From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3 net-next 1/2] net/ipv6: allow sysctl to change
 link-local address generation mode
Date: Thu, 19 Jan 2017 17:27:10 -0800
Message-ID: <20170119172710.57eda5d0@xeon-e3>
References: <20170119224619.18656-1-felix.jia@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>,
        Hermin Anggawijaya <hermin.anggawijaya@alliedtelesis.co.nz>
To: Felix Jia <felix.jia@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:35819 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753752AbdATB1l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 20:27:41 -0500
Received: by mail-pg0-f51.google.com with SMTP id 194so18656760pgd.2
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 17:27:18 -0800 (PST)
In-Reply-To: <20170119224619.18656-1-felix.jia@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Jan 2017 11:46:19 +1300
Felix Jia <felix.jia@alliedtelesis.co.nz> wrote:

> diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
> index 0fa4c324b713..48e2a34a6ed3 100644
> --- a/include/net/if_inet6.h
> +++ b/include/net/if_inet6.h
> @@ -1,9 +1,9 @@
>  /*
>   *	inet6 interface/address list definitions
> - *	Linux INET6 implementation 
> + *	Linux INET6 implementation
>   *
>   *	Authors:
> - *	Pedro Roque		<roque@di.fc.ul.pt>	
> + *	Pedro Roque		<roque@di.fc.ul.pt>

Please don't add unnecessary whitespace changes to  your patch.
