From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH 2/2] net: ethernet: ethoc: use
 phy_ethtool_{get|set}_link_ksettings
Date: Mon, 27 Jun 2016 08:35:20 +0200
Message-ID: <20160627063520.GI28466@distanz.ch>
References: <1466865222-11840-1-git-send-email-tremyfr@gmail.com>
 <1466865222-11840-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, andrew@lunn.ch, colin.king@canonical.com,
	f.fainelli@gmail.com, jcmvbkbc@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:59389 "EHLO sym2.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751639AbcF0Glv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 02:41:51 -0400
Content-Disposition: inline
In-Reply-To: <1466865222-11840-2-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-06-25 at 16:33:42 +0200, Philippe Reynes <tremyfr@gmail.com> wrote:
> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Reviewed-by: Tobias Klauser <tklauser@distanz.ch>

Thanks
