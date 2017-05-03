From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v4 net-next 06/10] net/ncsi: Ethtool operation to get
 NCSI hw statistics
Date: Wed, 3 May 2017 14:47:22 +0200
Message-ID: <20170503124722.GE8029@lunn.ch>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1493786681-27468-7-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, joe@perches.com, kubakici@wp.pl,
        f.fainelli@gmail.com, davem@davemloft.net
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49006 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751488AbdECMr2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 3 May 2017 08:47:28 -0400
Content-Disposition: inline
In-Reply-To: <1493786681-27468-7-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 03, 2017 at 02:44:37PM +1000, Gavin Shan wrote:
> This adds ethtool command (ETHTOOL_GNCSISTATS) to retrieve the
> NCSI hardware statistics.

Hi Gavin

I've not been following this patchset, so maybe i'm about to ask a
question which has already been asked and answered.

Why cannot use just use ethtool -S for this?

    Andrew
