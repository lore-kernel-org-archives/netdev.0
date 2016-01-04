From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 02/24] mdio: Move mdiobus_read/write operatings
 into mdio.h
Date: Mon, 04 Jan 2016 12:02:09 -0800
Message-ID: <568ACFC1.2080608@gmail.com>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch> <1451929022-5580-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35105 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569AbcADUCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 15:02:40 -0500
Received: by mail-pf0-f196.google.com with SMTP id e65so19610941pfe.2
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 12:02:40 -0800 (PST)
In-Reply-To: <1451929022-5580-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/16 09:36, Andrew Lunn wrote:
> These are logically MDIO operations, not phy operations, so move them
> into the mdio header.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
