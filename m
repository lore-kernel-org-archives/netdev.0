From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 10/11] net: bridge: Remove FDB deletion through switchdev object
Date: Tue, 18 Jul 2017 14:07:26 -0400
Message-ID: <874lu9bov5.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1500387624-4361-1-git-send-email-arkadis@mellanox.com> <1500387624-4361-11-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com,
        Arkadi Sharshevsky <arkadis@mellanox.com>
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:53338 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751391AbdGRSKI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 14:10:08 -0400
In-Reply-To: <1500387624-4361-11-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arkadi Sharshevsky <arkadis@mellanox.com> writes:

> At this point no driver supports FDB add/del through switchdev object
> but rather via notification chain, thus, it is removed.
>
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
