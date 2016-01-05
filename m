From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 18/24] phy: Move phy specific bus match into
 phy_device
Date: Mon, 04 Jan 2016 18:01:20 -0800
Message-ID: <568B23F0.8010806@gmail.com>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch> <1451929022-5580-19-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34272 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756AbcAECBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 21:01:52 -0500
Received: by mail-pf0-f172.google.com with SMTP id e65so158395366pfe.1
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 18:01:51 -0800 (PST)
In-Reply-To: <1451929022-5580-19-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/16 09:36, Andrew Lunn wrote:
> Matching a driver to a device has both generic parts, and parts which
> are specific to PHY devices. Move the PHY specific parts into
> phy_device.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
