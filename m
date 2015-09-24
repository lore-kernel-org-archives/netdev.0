From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mdio-octeon: Add PCI driver binding.
Date: Thu, 24 Sep 2015 15:16:28 -0700 (PDT)
Message-ID: <20150924.151628.127622905597225023.davem@davemloft.net>
References: <20150924.145206.897667718297700953.davem@davemloft.net>
	<56047367.3060101@caviumnetworks.com>
	<56047533.4020906@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ddaney.cavm@gmail.com, linux-kernel@vger.kernel.org,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	devicetree@vger.kernel.org, f.fainelli@gmail.com,
	netdev@vger.kernel.org, david.daney@cavium.com
To: ddaney@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54588 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753468AbbIXWQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 18:16:29 -0400
In-Reply-To: <56047533.4020906@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <ddaney@caviumnetworks.com>
Date: Thu, 24 Sep 2015 15:12:03 -0700

> Sorry for the breakage, I will fix it and resubmit.

Don't bother, I told you that using PCI probing is unacceptable.
