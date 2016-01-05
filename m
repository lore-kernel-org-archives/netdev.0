From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 13/24] phy: Add API for {un{registering an
 mdio device to a bus.
Date: Mon, 04 Jan 2016 17:55:24 -0800
Message-ID: <568B228C.2040608@gmail.com>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch> <1451929022-5580-14-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33158 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753859AbcAEBzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 20:55:55 -0500
Received: by mail-pa0-f47.google.com with SMTP id cy9so206218297pac.0
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 17:55:55 -0800 (PST)
In-Reply-To: <1451929022-5580-14-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/16 09:36, Andrew Lunn wrote:
> Rather than have drivers directly manipulate the mii_bus structure,
> provide and API for registering and unregistering devices on an MDIO
> bus, and performing lookups.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
