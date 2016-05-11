From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] phy: micrel: Use MICREL_PHY_ID_MASK definition
Date: Wed, 11 May 2016 14:29:57 -0700
Message-ID: <5733A455.4050701@gmail.com>
References: <1462996925-7153-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@nxp.com>
To: Fabio Estevam <festevam@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:32945 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563AbcEKVaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 17:30:00 -0400
Received: by mail-pa0-f68.google.com with SMTP id gh9so4405584pac.0
        for <netdev@vger.kernel.org>; Wed, 11 May 2016 14:30:00 -0700 (PDT)
In-Reply-To: <1462996925-7153-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/11/2016 01:02 PM, Fabio Estevam wrote:
> From: Fabio Estevam <fabio.estevam@nxp.com>
> 
> Replace the hardcoded mask 0x00fffff0 with MICREL_PHY_ID_MASK for
> better readability.
> 
> Suggested-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
