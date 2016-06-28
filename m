From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/6] net: dsa: Platform data for dsa2.c
Date: Tue, 28 Jun 2016 03:05:51 +0200
Message-ID: <20160628010551.GD26597@lunn.ch>
References: <1467075163-15890-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58855 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751942AbcF1BFy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 21:05:54 -0400
Content-Disposition: inline
In-Reply-To: <1467075163-15890-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2016 at 05:52:37PM -0700, Florian Fainelli wrote:
> Hi all,
> 
> This patch series adds support for platform data using the new code from
> net/dsa/dsa2.c. The motivation behind this is that we have a bit of in tree
> platforms (ar7, bcm47xx, x86, others) that could be benefiting from the new
> dsa_register_switch() API model but do not support Device Tree, nor is there a
> plan to bring Device Tree to these platforms (time vs. benefits).

Hi Florian

Please could you convert an in tree device to actually use this.

       Thanks
	Andrew
