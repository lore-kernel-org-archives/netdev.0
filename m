From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 22/24] mdio: Abstract device_remove() and
 device_free()
Date: Mon, 04 Jan 2016 18:04:26 -0800
Message-ID: <568B24AA.7090607@gmail.com>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch> <1451929022-5580-23-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36841 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753887AbcAECE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 21:04:57 -0500
Received: by mail-pa0-f48.google.com with SMTP id yy13so113835188pab.3
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 18:04:57 -0800 (PST)
In-Reply-To: <1451929022-5580-23-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/16 09:37, Andrew Lunn wrote:
> Make device_free and device_remove operations in the mdio device
> structure, so the core code does not need to differentiate between
> phy devices and generic mdio devices.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
