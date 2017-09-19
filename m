From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 08/12] net: dsa: b53: Move EEE functions to b53
Date: Tue, 19 Sep 2017 10:34:26 -0400
Message-ID: <87lglasqod.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170919021947.8971-1-f.fainelli@gmail.com> <20170919021947.8971-9-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: andrew@lunn.ch, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:39878 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750884AbdISOh6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 10:37:58 -0400
In-Reply-To: <20170919021947.8971-9-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> Move the bcm_sf2 EEE-related functions to the b53 driver because this is shared
> code amongst Gigabit capable switch, only 5325 and 5365 are too old to support
> that.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
