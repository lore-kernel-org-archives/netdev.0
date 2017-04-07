From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] net: dsa: Do not check for NULL dst in tag
 parsers
Date: Fri, 7 Apr 2017 22:54:27 +0200
Message-ID: <20170407205427.GC7966@lunn.ch>
References: <20170407204154.9651-1-f.fainelli@gmail.com>
 <20170407204154.9651-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50305 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751059AbdDGUy3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 16:54:29 -0400
Content-Disposition: inline
In-Reply-To: <20170407204154.9651-2-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 07, 2017 at 01:41:52PM -0700, Florian Fainelli wrote:
> dsa_switch_rcv() already tests for dst == NULL, so there is no need to duplicate
> the same check within the tag receive functions.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
