From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 1/3] net: dsa: mv88e6xxx: remove unused
 phy_mutex
Date: Thu, 21 Jul 2016 02:36:17 +0200
Message-ID: <20160721003617.GC22834@lunn.ch>
References: <20160720221836.28218-1-vivien.didelot@savoirfairelinux.com>
 <20160720221836.28218-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46738 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752556AbcGUAgT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 20:36:19 -0400
Content-Disposition: inline
In-Reply-To: <20160720221836.28218-2-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2016 at 06:18:34PM -0400, Vivien Didelot wrote:
> Only reg_lock is necessary now and phy_mutex is dead. Remove it.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
