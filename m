From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Duplicate MDIO_XGENE Kconfig entries
Date: Thu, 6 Oct 2016 18:37:36 +0200
Message-ID: <20161006163736.GA16941@lunn.ch>
References: <5fed0550-56d1-d019-86bf-2a882c0bf457@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Laura Abbott <labbott@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40242 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S942075AbcJFQhn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Oct 2016 12:37:43 -0400
Content-Disposition: inline
In-Reply-To: <5fed0550-56d1-d019-86bf-2a882c0bf457@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 06, 2016 at 09:01:27AM -0700, Laura Abbott wrote:
> Hi,
> 
> While working on the Fedora tree today, I noticed that there
> seem to be two entries for CONFIG_MDIO_XGENE. It looks like
> this might have been fall out from d75b4a22b255 ("net: phy:
> Sort Makefile and Kconfig"). I can submit the following if
> this isn't fixed up elsewhere already

Hi Laura

I don't remember seeing a fix for this going by. Please do submit a
follow up.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
