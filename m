From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 07/17] net: dsa: Remove dynamic allocate of
 routing table
Date: Fri, 3 Jun 2016 14:11:31 -0700
Message-ID: <5751F283.5030100@gmail.com>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
 <1464972256-10408-8-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33072 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932422AbcFCVLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 17:11:33 -0400
Received: by mail-pa0-f46.google.com with SMTP id ec8so11701556pac.0
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 14:11:33 -0700 (PDT)
In-Reply-To: <1464972256-10408-8-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2016 09:44 AM, Andrew Lunn wrote:
> With a maximum of four switches, the size of the routing table is the
> same as the pointer to it. Removing it makes the code simpler.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
