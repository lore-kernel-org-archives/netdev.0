From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] net: dsa: Mop up remaining NET_DSA_HWMON references
Date: Wed, 25 Jan 2017 17:03:32 +0100
Message-ID: <20170125160332.GA6611@lunn.ch>
References: <1485353057-4612-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, valentinrothberg@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45783 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750729AbdAYQDg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Jan 2017 11:03:36 -0500
Content-Disposition: inline
In-Reply-To: <1485353057-4612-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 25, 2017 at 03:04:17PM +0100, Andrew Lunn wrote:
> Previous patches have moved the temperature sensor code into the
> Marvell PHYs. A few now dead references to NET_DSA_HWMON were left
> behind. Go reap them.

Hi David

Wrong subject line. This should be net-next, which is why 0-day has
found issues. It applied it to the wrong branch.

      Andrew
