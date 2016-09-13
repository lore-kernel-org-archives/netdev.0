From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] MAINTAINERS: Add an entry for the core network
 DSA code
Date: Tue, 13 Sep 2016 12:01:51 -0700
Message-ID: <b83db123-e76a-0f27-39f9-5352899b5346@gmail.com>
References: <1473793231-26130-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:36384 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932416AbcIMTBz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 15:01:55 -0400
Received: by mail-pa0-f66.google.com with SMTP id p2so3306650pap.3
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 12:01:55 -0700 (PDT)
In-Reply-To: <1473793231-26130-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/13/2016 12:00 PM, Andrew Lunn wrote:
> The core distributed switch architecture code currently does not have
> a MAINTAINERS entry, which results in some contributions not landing
> in the right peoples inbox.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  MAINTAINERS | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index ce80b36aab69..98cf0c4a14cf 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -8169,6 +8169,13 @@ S:	Maintained
>  W:	https://fedorahosted.org/dropwatch/
>  F:	net/core/drop_monitor.c
>  
> +NETWORKING [DSA]
> +M:	Andrew Lunn <andrew@lunn.ch>
> +M:	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> +M:	Florian Fainelli <f.fainelli@gmail.com>
> +S:	Maintained
> +F:	net/dsa/

F:	include/net/dsa.h
F:	drivers/net/dsa/

Other than that, LGTM
-- 
Florian
