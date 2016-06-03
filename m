From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 08/17] net: dsa: Copy the routing table into the
 switch structure
Date: Fri, 3 Jun 2016 14:21:28 -0700
Message-ID: <5751F4D8.6040902@gmail.com>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
 <1464972256-10408-9-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34711 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752766AbcFCVVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 17:21:30 -0400
Received: by mail-pf0-f173.google.com with SMTP id 62so47233097pfd.1
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 14:21:30 -0700 (PDT)
In-Reply-To: <1464972256-10408-9-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2016 09:44 AM, Andrew Lunn wrote:
> The new binding will not have a chip data structure, it will place the
> routing directly into the switch structure. To enable backwards
> compatibility, copy the routing from the chip data into the switch
> structure.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
