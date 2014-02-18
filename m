From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Documentation: broadcom-bcmgenet: fix address and
 cells properties
Date: Tue, 18 Feb 2014 17:23:58 -0500 (EST)
Message-ID: <20140218.172358.664228775501919671.davem@davemloft.net>
References: <1392683255-28136-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36564 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752534AbaBRWYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 17:24:00 -0500
In-Reply-To: <1392683255-28136-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 17 Feb 2014 16:27:35 -0800

> This patch fixes a typo in the Device Tree binding for the
> leading '#'.
> 
> Reported-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Sergei put the phy-mode documentation to a common location, so you'll
need to respin this.

Thanks.
