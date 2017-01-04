From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH repost net-next] dsa: mv88e6xxx: Optimise atu_get
Date: Wed, 4 Jan 2017 22:45:51 +0100
Message-ID: <20170104214551.GF4229@lunn.ch>
References: <1483556184-4176-1-git-send-email-andrew@lunn.ch>
 <20170104.161103.175830630875484681.davem@davemloft.net>
 <20170104211957.GD4229@lunn.ch>
 <20170104.162718.86114638722981428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: volodymyr.bendiuga@gmail.com, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44178 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750722AbdADVp4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 16:45:56 -0500
Content-Disposition: inline
In-Reply-To: <20170104.162718.86114638722981428.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Maybe I over-reacted.

I'm happy somebody other than me is thinking about this.

> I just ran some test programs in userspace on both little and big
> endian and they checked out.

Great, thanks for testing.

       Andrew
