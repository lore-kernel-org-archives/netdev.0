From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] net: dsa: code re-organization
Date: Fri, 06 Mar 2015 00:18:55 -0500 (EST)
Message-ID: <20150306.001855.2219598159441758214.davem@davemloft.net>
References: <1425587708-26786-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39986 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500AbbCFFTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 00:19:00 -0500
In-Reply-To: <1425587708-26786-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu,  5 Mar 2015 12:35:03 -0800

> This pull request contains the first part of the patches required to implement
> the grand plan detailed here:
> 
> http://www.spinics.net/lists/netdev/msg295942.html
> 
> These are mostly code re-organization and function bodies re-arrangement to
> allow different callers of lower-level initialization functions for 'struct
> dsa_switch' and 'struct dsa_switch_tree' to be later introduced.
> 
> There is no functional code change at this point.

Looks great, applied, thanks Florian.
