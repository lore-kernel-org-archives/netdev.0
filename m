From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 15/18] net: dsa: mv88e6xxx: make VTU helpers
 static
Date: Fri, 28 Apr 2017 04:15:54 +0200
Message-ID: <20170428021554.GE13231@lunn.ch>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
 <20170426155336.5937-16-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44004 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S968656AbdD1CP4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 22:15:56 -0400
Content-Disposition: inline
In-Reply-To: <20170426155336.5937-16-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 11:53:33AM -0400, Vivien Didelot wrote:
> Now that we have chip operations for VTU accesses, mark all helpers from
> global1_vtu.c as static. Only the various implementations of the
> GetNext, LoadPurge and Flush operations need to be exposed.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
