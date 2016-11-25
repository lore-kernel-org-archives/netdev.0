From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/2] Fix support for the MV88E6097
Date: Fri, 25 Nov 2016 15:27:18 +0100
Message-ID: <20161125142718.GD26806@lunn.ch>
References: <20161125084130.3210-1-stefan.eichenberger@netmodule.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, davem@davemloft.net,
        netdev@vger.kernel.org,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
To: Stefan Eichenberger <eichest@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55849 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754627AbcKYPKc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Nov 2016 10:10:32 -0500
Content-Disposition: inline
In-Reply-To: <20161125084130.3210-1-stefan.eichenberger@netmodule.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 25, 2016 at 09:41:28AM +0100, Stefan Eichenberger wrote:
> This patchset fixes the following two issues for the MV88E6097:
> - Add missing definition of g1_irqs
> - Add missing comment
> 
> Stefan Eichenberger (2):
>   net: dsa: mv88e6xxx: add g1_irqs definition for MV88E6097
>   net: dsa: mv88e6xxx: add missing comment for MV88E6097
> 
>  drivers/net/dsa/mv88e6xxx/chip.c | 2 ++
>  1 file changed, 2 insertions(+)

Hi Stefan

Thanks for the delta patches.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
