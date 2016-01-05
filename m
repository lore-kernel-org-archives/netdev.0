From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 17/24] phy: Centralize setting driver module
 owner
Date: Mon, 04 Jan 2016 18:00:48 -0800
Message-ID: <568B23D0.3050901@gmail.com>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch> <1451929022-5580-18-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35001 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756AbcAECBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 21:01:19 -0500
Received: by mail-pa0-f50.google.com with SMTP id do7so5642573pab.2
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 18:01:19 -0800 (PST)
In-Reply-To: <1451929022-5580-18-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/16 09:36, Andrew Lunn wrote:
> Rather than have each driver set the driver owner field, do it once in
> the core code. This will also help with later changes, when the device
> structure will move.

Another thing that should have been taken care of long before, thanks!
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
