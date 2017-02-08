From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: Fix duplicate object rule
Date: Wed, 08 Feb 2017 17:43:44 -0500
Message-ID: <8760kk2ti7.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170208224004.11786-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:45814 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751025AbdBHWpY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 17:45:24 -0500
In-Reply-To: <20170208224004.11786-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> While adding switch.o to the list of DSA object files, we essentially
> duplicated the previous obj-y line and just added switch.o, remove the
> duplicate.
>
> Fixes: f515f192ab4f ("net: dsa: add switch notifier")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

My bad, thanks!

   Vivien
