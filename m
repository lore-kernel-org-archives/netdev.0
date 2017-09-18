From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 06/12] net: dsa: b53: Move Broadcom header setup to b53
Date: Mon, 18 Sep 2017 18:14:30 -0400
Message-ID: <87tvzz1wop.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170918214128.27896-1-f.fainelli@gmail.com> <20170918214128.27896-7-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:35570 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750822AbdIRWSC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 18:18:02 -0400
In-Reply-To: <20170918214128.27896-7-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> The code to enable Broadcom tags/headers is largely switch independent,
> and in preparation for enabling it for multiple devices with b53, move
> the code we have in bcm_sf2.c to b53_common.c
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
