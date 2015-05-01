From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: unregister mv88e6352 driver
Date: Fri, 1 May 2015 11:01:02 -0700
Message-ID: <20150501180102.GD7712@roeck-us.net>
References: <1430491432-7566-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:47196 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750728AbbEASBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 14:01:19 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.85)
	(envelope-from <linux@roeck-us.net>)
	id 1YoFFW-000RnE-7B
	for netdev@vger.kernel.org; Fri, 01 May 2015 18:01:18 +0000
Content-Disposition: inline
In-Reply-To: <1430491432-7566-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 01, 2015 at 10:43:52AM -0400, Vivien Didelot wrote:
> Add the missing unregister for the mv88e6352_switch_driver.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Guenter Roeck <linux@roeck-us.net>
