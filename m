From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 12/17] net: dsa: Make mdio bus optional
Date: Fri, 3 Jun 2016 10:21:03 -0700
Message-ID: <5751BC7F.6050809@gmail.com>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
 <1464972256-10408-13-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33845 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752937AbcFCRVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 13:21:06 -0400
Received: by mail-pf0-f169.google.com with SMTP id 62so45590708pfd.1
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 10:21:05 -0700 (PDT)
In-Reply-To: <1464972256-10408-13-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2016 09:44 AM, Andrew Lunn wrote:
> The switch may want to instantiate its own MDIO bus. Only do it
> centrally if the switch has not already created one, and the read op
> is implemented.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
