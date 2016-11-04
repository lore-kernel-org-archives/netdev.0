From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/5] ethtool: (uapi) Add ETHTOOL_PHY_GTUNABLE
 and ETHTOOL_PHY_STUNABLE
Date: Fri, 4 Nov 2016 13:29:35 +0100
Message-ID: <20161104122935.GL13959@lunn.ch>
References: <1478255742-25693-1-git-send-email-allan.nielsen@microsemi.com>
 <1478255742-25693-2-git-send-email-allan.nielsen@microsemi.com>
 <20161104120343.GI13959@lunn.ch>
 <20161104121841.GA5676@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        raju.lakkaraju@microsemi.com, cphealy@gmail.com, robh@kernel.org
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36828 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933163AbcKDM3h (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 08:29:37 -0400
Content-Disposition: inline
In-Reply-To: <20161104121841.GA5676@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> It was "just" to mimic how "tunable_type_id/ETHTOOL_TUNABLE_UNSPEC" (and other)
> is done.

Yes, i know. I'm wondering about cult cargo programming...

> The thinking was that we did not want an "ID" of zero do to anything - because
> that could mean the programmer had forgot to set the field...

Seems reasonable. Leave it as is.

      Andrew
