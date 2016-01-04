From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 06/24] net: dnet: Use phy_find_first() helper
Date: Mon, 04 Jan 2016 12:08:45 -0800
Message-ID: <568AD14D.9040909@gmail.com>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch> <1451929022-5580-7-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:33055 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990AbcADUJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 15:09:16 -0500
Received: by mail-pa0-f65.google.com with SMTP id pv5so16598696pac.0
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 12:09:16 -0800 (PST)
In-Reply-To: <1451929022-5580-7-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/16 09:36, Andrew Lunn wrote:
> Replace the open coded search for the first phy with a call to the
> existing helper function.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
