From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: add MV88E6097 switch
Date: Tue, 22 Nov 2016 16:07:54 +0100
Message-ID: <20161122150754.GF2691@lunn.ch>
References: <20161122102836.23980-1-stefan.eichenberger@netmodule.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
To: Stefan Eichenberger <eichest@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48489 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755911AbcKVPH4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Nov 2016 10:07:56 -0500
Content-Disposition: inline
In-Reply-To: <20161122102836.23980-1-stefan.eichenberger@netmodule.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 22, 2016 at 11:28:36AM +0100, Stefan Eichenberger wrote:
> Add support for the MV88E6097 switch. The change was tested on an Armada
> based platform with a MV88E6097 switch.

Hi Stefan

Please can you based your patches on net-next. You will then find the
ops structure has gained a few more entries.

    Andrew
