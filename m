From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 09/12] net: dsa: b53: Wire-up EEE
Date: Tue, 19 Sep 2017 10:37:38 -0400
Message-ID: <87ingesqj1.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170919021947.8971-1-f.fainelli@gmail.com> <20170919021947.8971-10-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: andrew@lunn.ch, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:40026 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750733AbdISOlJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 10:41:09 -0400
In-Reply-To: <20170919021947.8971-10-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> Add support for enabling and disabling EEE, as well as re-negotiating it in
> .adjust_link() and in .port_enable().
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
