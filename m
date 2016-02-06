From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net 0/4] net: phy: bcm7xxx 40nm PHY fixes
Date: Fri, 5 Feb 2016 17:25:50 -0800
Message-ID: <56B54B9E.20906@gmail.com>
References: <1454534029-585-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, pgynther@google.com, opendmb@gmail.com,
	jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34870 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbcBFB0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 20:26:54 -0500
Received: by mail-pf0-f179.google.com with SMTP id c10so11181100pfc.2
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 17:26:54 -0800 (PST)
In-Reply-To: <1454534029-585-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/16 13:13, Florian Fainelli wrote:
> Hi David,
> 
> Here is a collection of fixes for the 40nm Ethernet PHY supported
> by the 7xxx PHY driver, please also queue these fixes for stable.
> 
> Let me know if you think patch 4 is too much of a cleanup to be taken
> as a fix.

David, if you have not applied these yet (patchwork says they are under
review), I have another fix coming your way, and patch 4 should probably
be targetted at net-next, and bundled with another cleanup.

Let me know what's the outcome and I will re-submit where appropriate,
thanks!
-- 
Florian
