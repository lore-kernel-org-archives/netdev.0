From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v7 net-next] net: phy: Add Edge-rate driver for Microsemi
 PHYs.
Date: Tue, 4 Oct 2016 16:34:50 +0200
Message-ID: <20161004143450.GP11677@lunn.ch>
References: <1475589845-29182-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        f.fainelli@gmail.com, Allan.Nielsen@microsemi.com
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38696 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751919AbcJDOey (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Oct 2016 10:34:54 -0400
Content-Disposition: inline
In-Reply-To: <1475589845-29182-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> v7:
> - As per review comment, Removed '-'s (minus) sign in Edge rate table. 

Still no exact match on the table. 

So if i specify a voltage of 3301, 53% slowdown it looks i will
actually get 0% slowdown and no error message. That is not very
helpful.

	Andrew
