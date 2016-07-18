From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next v2 02/12] net: dsa: mv88e6xxx: split setup of
 Global 1 and 2
Date: Mon, 18 Jul 2016 21:27:36 +0200
Message-ID: <20160718192736.GI31103@lunn.ch>
References: <20160718184628.13103-1-vivien.didelot@savoirfairelinux.com>
 <20160718184628.13103-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44937 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751847AbcGRT1i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 15:27:38 -0400
Content-Disposition: inline
In-Reply-To: <20160718184628.13103-3-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 18, 2016 at 02:46:18PM -0400, Vivien Didelot wrote:
> Separate the setup of Global 1 and Global 2 internal SMI devices and add
> a flag to describe the presence of this second registers set.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
