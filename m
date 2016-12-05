From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: Use EDSA on mv88e6097
Date: Mon, 5 Dec 2016 15:12:55 +0100
Message-ID: <20161205141255.GJ30716@lunn.ch>
References: <20161205131242.19370-1-stefan.eichenberger@netmodule.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
To: Stefan Eichenberger <eichest@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40566 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750998AbcLEONl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 09:13:41 -0500
Content-Disposition: inline
In-Reply-To: <20161205131242.19370-1-stefan.eichenberger@netmodule.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 05, 2016 at 02:12:42PM +0100, Stefan Eichenberger wrote:
> Use DSA_TAG_PROTO_EDSA as tag_protocol for the mv88e6097. The 
> initialisation was missing before.
> 
> Signed-off-by: Stefan Eichenberger <stefan.eichenberger@netmodule.com>

Upps, sorry. My error.

This is net-next only.

Fixes: a1f482aa8c33 ("net: dsa: mv88e6xxx: Move the tagging protocol into info")
Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
