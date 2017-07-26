From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V2 1/4] net-next: dsa: move struct dsa_device_ops to the
 global header file
Date: Wed, 26 Jul 2017 16:53:16 +0200
Message-ID: <20170726145316.GC12049@lunn.ch>
References: <20170721085813.30789-1-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40871 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751011AbdGZOx1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 10:53:27 -0400
Content-Disposition: inline
In-Reply-To: <20170721085813.30789-1-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 21, 2017 at 10:58:10AM +0200, John Crispin wrote:
> We need to access this struct from within the flow_dissector to fix
> dissection for packets coming in on DSA devices.
> 
> Signed-off-by: John Crispin <john@phrozen.org>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
