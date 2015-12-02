From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next v2 02/28] net: Add support for CHANGEUPPER
 notifier error injection
Date: Wed, 2 Dec 2015 21:23:15 +0100
Message-ID: <565F5333.8090907@cumulusnetworks.com>
References: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
 <1449086871-19911-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, pjonnala@broadcom.com,
	f.fainelli@gmail.com, sfeldma@gmail.com, john.fastabend@gmail.com,
	roopa@cumulusnetworks.com, andrew@lunn.ch
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35919 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881AbbLBUXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 15:23:18 -0500
Received: by wmww144 with SMTP id w144so230786430wmw.1
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 12:23:16 -0800 (PST)
In-Reply-To: <1449086871-19911-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/02/2015 09:07 PM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> Since CHANGEUPPER can now fail, add support for it in the newly
> introduced netdev notifier error injection infrastructure.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> v1->v2:
> -new patch
> ---
>  Documentation/fault-injection/notifier-error-inject.txt | 1 +
>  lib/netdev-notifier-error-inject.c                      | 1 +
>  2 files changed, 2 insertions(+)
> 

Thanks,

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
