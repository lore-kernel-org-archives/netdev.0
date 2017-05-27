From: Shawn Guo <shawnguo@kernel.org>
Subject: Re: [PATCH 2/2] ARM: VF610: ZII devel b: Add switch eeprom-length
 properties
Date: Sat, 27 May 2017 16:10:38 +0800
Message-ID: <20170527081036.GA4528@dragon>
References: <1495755884-31341-1-git-send-email-andrew@lunn.ch>
 <1495755884-31341-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        linux ARM <linux-arm-kernel@lists.infradead.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:47080 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751951AbdE0ILf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 27 May 2017 04:11:35 -0400
Content-Disposition: inline
In-Reply-To: <1495755884-31341-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 26, 2017 at 01:44:44AM +0200, Andrew Lunn wrote:
> Two of the Ethernet switches on this board have EEPROMs connected.
> Add the eeprom-length property to the device tree, making it possible
> to access the EEPROM using ethtool -e.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied with a bit update on subject prefix.  Thanks.

Shawn
