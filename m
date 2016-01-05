From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 19/24] mdio_bus: Generalise of_mdiobus_link_phydev()
Date: Mon, 04 Jan 2016 18:01:57 -0800
Message-ID: <568B2415.9070908@gmail.com>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch> <1451929022-5580-20-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33314 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756AbcAECC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 21:02:29 -0500
Received: by mail-pa0-f48.google.com with SMTP id cy9so206310404pac.0
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 18:02:29 -0800 (PST)
In-Reply-To: <1451929022-5580-20-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/16 09:36, Andrew Lunn wrote:
> This function should work with any sort of MDIO device which can be
> probed on the bus, not just PHY devices. So generalise it.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
