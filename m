From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 0/4] net: phy: Register header file for Microsemi PHYs.
Date: Fri, 26 Aug 2016 15:40:28 +0200
Message-ID: <20160826134028.GE25046@lunn.ch>
References: <646450A91FAED74E85C6E9C4D6E936A14533665A@avsrvexchmbx1.microsemi.net>
 <b0fe05bc-d6c4-0692-44ba-69ff8db3026a@gmail.com>
 <20160826102219.GA22159@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Allan Nielsen <Allan.Nielsen@microsemi.com>
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45060 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751449AbcHZNkb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 Aug 2016 09:40:31 -0400
Content-Disposition: inline
In-Reply-To: <20160826102219.GA22159@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I would like to share these register definitions share between
> Microsemi multiple drivers.

Hi Raju

Please post a patch which does this, i.e. modifies multiple drivers to
share the header file.

However, just be aware, if it turns out these multiple drivers are
very similar, we might actually ask you to merge them into one driver.

     Andrew
