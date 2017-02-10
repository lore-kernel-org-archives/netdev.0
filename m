From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: cafe8df8b9bc clashes with DSA
Date: Fri, 10 Feb 2017 12:55:44 -0500
Message-ID: <87wpcyq6an.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <77093903.194093.1486748785802.JavaMail.zimbra@savoirfairelinux.com> <ccabc2d3-9589-f4f5-cdab-ee3ba40e8bc7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, andrew@lunn.ch
To: Florian Fainelli <f.fainelli@gmail.com>, maowenan@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:41736 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753246AbdBJR5u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 12:57:50 -0500
In-Reply-To: <ccabc2d3-9589-f4f5-cdab-ee3ba40e8bc7@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> Fixed in the "net" tree with:
>
> 6d9f66ac7fec2a6ccd649e5909806dfe36f1fc25 ("net: phy: Fix PHY module
> checks and NULL deref in phy_attach_direct()"), applies fine to net-next
> as well.

Correct, this fixes my setup. Shouldn't this be submitted to net-next as
well then?

Thanks,

        Vivien
