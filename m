From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/4] Marvell phy: add field to get errors from fiber link.
Date: Mon, 18 Jul 2016 17:33:37 +0200
Message-ID: <20160718153337.GK19265@lunn.ch>
References: <1468832623-1792-1-git-send-email-charles-antoine.couret@nexvision.fr>
 <1468832623-1792-3-git-send-email-charles-antoine.couret@nexvision.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cacouret.renault@gmail.com, netdev@vger.kernel.org
To: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44731 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751487AbcGRPdk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 11:33:40 -0400
Content-Disposition: inline
In-Reply-To: <1468832623-1792-3-git-send-email-charles-antoine.couret@nexvision.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 18, 2016 at 11:03:41AM +0200, Charles-Antoine Couret wrote:
> Add support for the fiber receiver error counter in the
> statistics. Rename the current counter which is for copper errors to
> phy_receive_errors_copper, so it is easy to distinguish copper from
> fiber.
> 
> Signed-off-by: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
