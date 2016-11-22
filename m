From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: egress all frames
Date: Tue, 22 Nov 2016 17:15:25 -0500
Message-ID: <87zikr40w2.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <20161122103944.31381-1-stefan.eichenberger@netmodule.com> <20161122150330.GE2691@lunn.ch> <20161122183732.GD13973@gruene.netmodule.intranet> <20161122190206.GE14947@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stefan Eichenberger <eichest@gmail.com>, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:59540 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934033AbcKVWPc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 17:15:32 -0500
In-Reply-To: <20161122190206.GE14947@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew, Stefan,

Andrew Lunn <andrew@lunn.ch> writes:

> What you might find useful is
>
> https://github.com/vivien/linux.git 161b96bd7d16d21b0f046c935b70c3b2d277ccc2
>
> although it might need some changes for recent commits.
>
> With that, you can see deeper into the switches registers.

FYI, I have rebased it on top of the latest net-next (f9aa9dc7d2d0):

    https://github.com/vivien/linux.git dsa/dev

Thanks,

        Vivien
