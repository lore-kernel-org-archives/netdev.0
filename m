From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 04/24] phy: Add phydev_err() and phydev_dbg()
 macros
Date: Mon, 04 Jan 2016 12:08:20 -0800
Message-ID: <568AD134.8040109@gmail.com>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch> <1451929022-5580-5-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36393 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751938AbcADUIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 15:08:51 -0500
Received: by mail-pf0-f195.google.com with SMTP id q63so18480373pfb.3
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 12:08:51 -0800 (PST)
In-Reply-To: <1451929022-5580-5-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/16 09:36, Andrew Lunn wrote:
> In preparation for moving some of the phy_device structure members,
> add macros for printing errors and debug information.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
