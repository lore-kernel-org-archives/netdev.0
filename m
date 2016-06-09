From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 5/8] net: dsa: mv88e6xxx: add switch register
 helpers
Date: Thu, 9 Jun 2016 04:39:34 +0200
Message-ID: <20160609023934.GK2227@lunn.ch>
References: <20160609004456.5441-1-vivien.didelot@savoirfairelinux.com>
 <20160609004456.5441-6-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39466 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1426351AbcFICjh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2016 22:39:37 -0400
Content-Disposition: inline
In-Reply-To: <20160609004456.5441-6-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 08, 2016 at 08:44:53PM -0400, Vivien Didelot wrote:
> Extract the allocation and registration code related to the dsa_switch
> structure in a mv88e6xxx_register_switch helper function.
> 
> For symmetry in the code, add a mv88e6xxx_unregister_switch function.

You say what you are doing, but not why?

    Andrew
