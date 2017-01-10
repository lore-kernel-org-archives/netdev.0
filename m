From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 2/2] Revert "net: dsa: Implement ndo_get_phys_port_id"
Date: Tue, 10 Jan 2017 15:44:45 -0500
Message-ID: <877f623arm.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170110203237.23907-1-f.fainelli@gmail.com> <20170110203237.23907-3-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch, jiri@resnulli.us,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:45856 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751630AbdAJUpJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 15:45:09 -0500
In-Reply-To: <20170110203237.23907-3-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> This reverts commit 3a543ef479868e36c95935de320608a7e41466ca ("net: dsa:
> Implement ndo_get_phys_port_id") since it misuses the purpose of
> ndo_get_phys_port_id(). We have ndo_get_phys_port_name() to do the
> correct thing for us now.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
