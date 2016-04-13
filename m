From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 net-next 6/7] dsa: Rename phys_port_mask to
 enabled_port_mask
Date: Wed, 13 Apr 2016 12:29:13 -0700
Message-ID: <570E9E09.4000807@gmail.com>
References: <1460508045-20254-1-git-send-email-andrew@lunn.ch>
 <1460508045-20254-7-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35623 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005AbcDMTbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 15:31:18 -0400
Received: by mail-pf0-f196.google.com with SMTP id r187so4920938pfr.2
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 12:31:17 -0700 (PDT)
In-Reply-To: <1460508045-20254-7-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/16 17:40, Andrew Lunn wrote:
> The phys in phys_port_mask suggests this mask is about PHYs. In fact,
> it means physical ports. Rename to enabled_port_mask, indicating
> external enabled ports of the switch, which is hopefully less
> confusing.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> Tested-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
