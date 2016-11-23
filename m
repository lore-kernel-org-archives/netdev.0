From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 0/2] Add support for the MV88e6097
Date: Wed, 23 Nov 2016 13:09:57 -0500
Message-ID: <87vavevzii.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <20161123175546.31416-1-stefan.eichenberger@netmodule.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
To: Stefan Eichenberger <eichest@gmail.com>, andrew@lunn.ch,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:36860 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751035AbcKWSKD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 13:10:03 -0500
In-Reply-To: <20161123175546.31416-1-stefan.eichenberger@netmodule.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stefan,

Stefan Eichenberger <eichest@gmail.com> writes:

> This patchset will add support for the MV88E6097 DSA switch and enable
> EDSA on MV88E6097 family devices.
>
> Stefan Eichenberger (2):
>   net: dsa: mv88e6xxx: add MV88E6097 switch
>   net: dsa: mv88e6xxx: enable EDSA on mv88e6097
>
>  drivers/net/dsa/mv88e6xxx/chip.c      | 26 ++++++++++++++++++++++++++
>  drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  5 ++++-
>  2 files changed, 30 insertions(+), 1 deletion(-)

Ideally I'd put 2/2 first, because right after 1/2 your switch won't
work as expected.

Thanks,

        Vivien
