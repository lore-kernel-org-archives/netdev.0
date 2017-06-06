From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 4/5] net: dsa: Introduce dsa_dst_get_cpu_dp()
Date: Tue, 06 Jun 2017 13:52:54 -0400
Message-ID: <878tl5knpl.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170606170202.21491-1-f.fainelli@gmail.com> <20170606170202.21491-5-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: andrew@lunn.ch, john@phrozen.org, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:33624 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751418AbdFFRzC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 13:55:02 -0400
In-Reply-To: <20170606170202.21491-5-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> Introduce a helper function which will return a reference to the CPU
> port used in a dsa_switch_tree. Right now this is a singleton, but this
> will change once we introduce multi-CPU port support, so ease the
> transition by converting the affected code paths.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
