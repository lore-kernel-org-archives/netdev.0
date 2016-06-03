From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 05/17] net: dsa: Add a ports structure and use it
 in the switch structure
Date: Fri, 3 Jun 2016 11:21:16 -0700
Message-ID: <5751CA9C.10402@gmail.com>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
 <1464972256-10408-6-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:34907 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932119AbcFCSVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 14:21:18 -0400
Received: by mail-pa0-f65.google.com with SMTP id gp3so6478702pac.2
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 11:21:18 -0700 (PDT)
In-Reply-To: <1464972256-10408-6-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2016 09:44 AM, Andrew Lunn wrote:
> There are going to be more per-port members added to the switch
> structure. So add a port structure and move the netdev into it.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
