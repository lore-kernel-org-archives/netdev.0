From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v3 05/13] net: dsa: Move FDB add/del implementation inside DSA
Date: Mon, 07 Aug 2017 09:56:47 -0400
Message-ID: <87mv7bmqg0.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com> <1502025351-41261-6-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch, Woojung.Huh@microchip.com,
        mlxsw@mellanox.com, Arkadi Sharshevsky <arkadis@mellanox.com>
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:56354 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750751AbdHGN7t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 09:59:49 -0400
In-Reply-To: <1502025351-41261-6-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arkadi Sharshevsky <arkadis@mellanox.com> writes:

> Currently DSA uses switchdev's implementation of FDB add/del ndos. This
> patch moves the implementation inside DSA in order to support the legacy
> way for static FDB configuration.
>
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
