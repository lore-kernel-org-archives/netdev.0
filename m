From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3] net: dsa: mv88e6xxx: enable EDSA on mv88e6097
Date: Wed, 23 Nov 2016 18:13:44 +0100
Message-ID: <20161123171344.GC8760@lunn.ch>
References: <20161123165949.GB8760@lunn.ch>
 <20161123171135.9768-1-stefan.eichenberger@netmodule.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
To: Stefan Eichenberger <eichest@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50062 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755059AbcKWRNr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 12:13:47 -0500
Content-Disposition: inline
In-Reply-To: <20161123171135.9768-1-stefan.eichenberger@netmodule.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2016 at 06:11:35PM +0100, Stefan Eichenberger wrote:
> EDSA is currently disabled on mv88e6097 devices, this commit enables it.

And was that sufficient to fix all your issues?

    Andrew
