From: David Miller <davem@davemloft.net>
Subject: Re: [Patch v2 RFT net-next 0/9] DSA port configuration and status
Date: Mon, 31 Aug 2015 14:48:21 -0700 (PDT)
Message-ID: <20150831.144821.1164259054387807786.davem@davemloft.net>
References: <1441029414-20062-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stsp@list.ru
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52197 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752876AbbHaVsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 17:48:25 -0400
In-Reply-To: <1441029414-20062-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Mon, 31 Aug 2015 15:56:45 +0200

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

Series applied, thanks Andrew.
