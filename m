From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 16/24] phy: Move PHY PM operations into phy_device
Date: Mon, 04 Jan 2016 18:00:14 -0800
Message-ID: <568B23AE.9020204@gmail.com>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch> <1451929022-5580-17-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33390 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756AbcAECAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 21:00:46 -0500
Received: by mail-pf0-f182.google.com with SMTP id q63so175361938pfb.0
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 18:00:46 -0800 (PST)
In-Reply-To: <1451929022-5580-17-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/16 09:36, Andrew Lunn wrote:
> The MDIO PM operations are really PHY device PM operations. So move
> them into phy_device. This will be needed when we support devices on
> the mdio bus which are not PHYs.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
