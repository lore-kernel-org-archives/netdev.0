From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 0/4] net: dsa: Make dsa_switch_ops const
Date: Mon, 09 Jan 2017 10:11:11 -0500
Message-ID: <874m1846b4.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170108225208.15431-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:39260 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966765AbdAIPLc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 10:11:32 -0500
In-Reply-To: <20170108225208.15431-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> This patch series allows us to annotate dsa_switch_ops with a const
> qualifier.
>
> Florian Fainelli (4):
>   net: dsa: b53: Export most operations to other drivers
>   net: dsa: bcm_sf2: Declare our own dsa_switch_ops
>   net: dsa: Encapsulate legacy switch drivers into dsa_switch_driver
>   net: dsa: Make dsa_switch_ops const

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

This is much cleaner now, thanks!

     Vivien
