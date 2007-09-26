From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [0/6] Bugfixes for pasemi_mac
Date: Wed, 26 Sep 2007 14:26:55 -0700 (PDT)
Message-ID: <20070926.142655.78181428.davem@davemloft.net>
References: <20070926212200.GA24168@lixom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: olof@lixom.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60801
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750919AbXIZV04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2007 17:26:56 -0400
In-Reply-To: <20070926212200.GA24168@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olof Johansson <olof@lixom.net>
Date: Wed, 26 Sep 2007 16:22:00 -0500

> [PATCH] [1/6] pasemi_mac: fix build break in pasemi_mac_probe()
> [PATCH] [2/6] pasemi_mac: fix build break in pasemi_mac_clean_rx()
> [PATCH] [3/6] pasemi_mac: set interface speed correctly on XAUI ports
> [PATCH] [4/6] pasemi_mac: flags as passed to spin_*_irqsave() should be unsigned long
> [PATCH] [5/6] pasemi_mac: don't enable rx before there are buffers on the ring
> [PATCH] [6/6] pasemi_mac: pass in count of buffers to replenish rx ring with

Jeff, patches #1 and #2 are taken care of in my net-2.6.24
tree, please review and take the rest, thanks!
