From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 21/24] mdio: Add support for mdio drivers.
Date: Mon, 04 Jan 2016 18:03:51 -0800
Message-ID: <568B2487.3010102@gmail.com>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch> <1451929022-5580-22-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34487 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756AbcAECEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 21:04:23 -0500
Received: by mail-pf0-f178.google.com with SMTP id e65so158431691pfe.1
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 18:04:23 -0800 (PST)
In-Reply-To: <1451929022-5580-22-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/16 09:36, Andrew Lunn wrote:
> Not all devices on an MDIO bus are PHYs. Meaning not all MDIO drivers
> are PHY drivers. Add support for generic MDIO drivers.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
