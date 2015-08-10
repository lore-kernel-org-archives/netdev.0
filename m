From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v3 0/8] net: dsa: mv88e6xxx: support switchdev
 FDB objects
Date: Mon, 10 Aug 2015 16:11:38 +0200
Message-ID: <20150810141138.GH14271@lunn.ch>
References: <1439212193-7673-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:56901 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754337AbbHJOSp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Aug 2015 10:18:45 -0400
Content-Disposition: inline
In-Reply-To: <1439212193-7673-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 10, 2015 at 09:09:45AM -0400, Vivien Didelot wrote:
> This patchset refactors the FDB management in the mv88e6xxx code and adds the
> glue in DSA to use the switchdev FDB objects.

Hi Vivien

Thanks for reworking these patches. Now they are much smaller, they
are much easier to review.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

	     Andrew
