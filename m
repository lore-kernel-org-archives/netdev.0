From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next] dsa:mv88e6xxx: allow address 0x1 in smi_init
Date: Wed, 7 Dec 2016 15:01:10 +0100
Message-ID: <20161207140110.GH18817@lunn.ch>
References: <1481102158-980-1-git-send-email-volodymyr.bendiuga@westermo.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, volodymyr.bendiuga@gmail.com
To: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47807 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751225AbcLGOCM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 09:02:12 -0500
Content-Disposition: inline
In-Reply-To: <1481102158-980-1-git-send-email-volodymyr.bendiuga@westermo.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 07, 2016 at 10:15:58AM +0100, Volodymyr Bendiuga wrote:
> Some devices, such as the mv88e6097 do have ADDR[0] external and so it
> is possible to configure the device to use SMI address 0x1. Remove the
> restriction, as there are boards using this address.
> 
> Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
