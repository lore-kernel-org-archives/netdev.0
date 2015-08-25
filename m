From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] DSA port configuration and status
Date: Tue, 25 Aug 2015 13:43:54 -0700 (PDT)
Message-ID: <20150825.134354.1040055031224195146.davem@davemloft.net>
References: <1440323220-20438-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59416 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755944AbbHYUnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 16:43:55 -0400
In-Reply-To: <1440323220-20438-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sun, 23 Aug 2015 11:46:51 +0200

> This patchset allows various switch port settings to be configured and
> port status to be sampled. Some of these patches have been posted
> before.
> 
> The first three patches provide infrastructure for configuring a
> switch ports link speed and duplex from a fixed_link phy.
> 
> Patch four then uses this infrastructure to allow the CPU and DSA
> ports of a switch to be configured using a fixed-link property in the
> device tree.
> 
> Patches five and six allow a phy-mode property to be specified in the
> device tree, and allow this to be used for configuring RGMII delays.
> 
> Patches seven through nine allow link status, for example that of an
> SFP module, to be read from a gpio.
> 
> Please don't merge these patches until Florian Fainelli has reviewed
> them.

It looks to me like there will be at least one more revision to this
series, so I'm not applying this version.
