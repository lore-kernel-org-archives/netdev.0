From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 2/5] net: dsa: Relocate master ethtool operations
Date: Tue, 06 Jun 2017 13:28:46 -0400
Message-ID: <87efuxkott.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170606170202.21491-1-f.fainelli@gmail.com> <20170606170202.21491-3-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: andrew@lunn.ch, john@phrozen.org, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:58506 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751200AbdFFRay (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 13:30:54 -0400
In-Reply-To: <20170606170202.21491-3-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> Relocate master_ethtool_ops and master_orig_ethtool_ops into struct
> dsa_port in order to be both consistent, and make things self contained
> within the dsa_port structure.
>
> This is a preliminary change to supporting multiple CPU port interfaces.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
