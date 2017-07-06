From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next RFC 03/12] net: dsa: Remove switchdev dependency from DSA switch notifier chain
Date: Thu, 06 Jul 2017 14:42:53 -0400
Message-ID: <87o9sxcspe.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1499268990-19251-1-git-send-email-arkadis@mellanox.com> <1499268990-19251-4-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com,
        Arkadi Sharshevsky <arkadis@mellanox.com>
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:53154 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752469AbdGFSpZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 14:45:25 -0400
In-Reply-To: <1499268990-19251-4-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arkadi Sharshevsky <arkadis@mellanox.com> writes:

> Currently, the switchdev objects are embedded inside the DSA notifier
> info. This patch removes this dependency. This is done as a preparation
> stage before adding support for learning FDB through the switchdev
> notification chain.
>
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
