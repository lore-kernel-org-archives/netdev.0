From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 2/2] net: dsa: mv88e6xxx: enable EDSA on mv88e6097
Date: Wed, 23 Nov 2016 13:21:23 -0500
Message-ID: <87wpfukqfw.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <20161123175546.31416-1-stefan.eichenberger@netmodule.com> <20161123175546.31416-3-stefan.eichenberger@netmodule.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
To: Stefan Eichenberger <eichest@gmail.com>, andrew@lunn.ch,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:37758 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753438AbcKWSVj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 13:21:39 -0500
In-Reply-To: <20161123175546.31416-3-stefan.eichenberger@netmodule.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stefan,

Stefan Eichenberger <eichest@gmail.com> writes:

> EDSA is currently disabled on mv88e6097 devices, this commit enables it.
>
> Signed-off-by: Stefan Eichenberger <stefan.eichenberger@netmodule.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

(you can include our Reviewed-by tags directly in the commit message of
this patch for v3, right under your Signed-off-by tag.)

Thanks,

        Vivien
