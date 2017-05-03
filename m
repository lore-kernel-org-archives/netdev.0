From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v4 net-next 00/10] net/ncsi: Add debugging functionality
Date: Wed, 3 May 2017 14:58:02 +0200
Message-ID: <20170503125802.GG8029@lunn.ch>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, joe@perches.com, kubakici@wp.pl,
        f.fainelli@gmail.com, davem@davemloft.net
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49038 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751176AbdECM6E (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 3 May 2017 08:58:04 -0400
Content-Disposition: inline
In-Reply-To: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 03, 2017 at 02:44:31PM +1000, Gavin Shan wrote:
> This series supports NCSI debugging infrastructure by adding several
> ethtool commands and one debugfs file. It was inspired by the reported
> issues: No available package and channel are probed successfully.
> Obviously, we don't have a debugging infrastructure for NCSI stack yet.
> 
> The first 3 patches, fixing some issues, aren't relevant to the
> subject. 

...

> PATCH[9,10] fix two issues found by the debugging functionality.

Hi Gavin

If they are real fixes, you should submit them separately. Please
include Fixes: tags, and indicate if they need to be included in
-stable.

David will probably accept fixes while the merge window is closed.

	Andrew
