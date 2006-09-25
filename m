From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: default congestion control menu
Date: Sun, 24 Sep 2006 20:12:29 -0700 (PDT)
Message-ID: <20060924.201229.97293889.davem@davemloft.net>
References: <20060919162355.3a22fec1@localhost.localdomain>
	<20060920081704.GA1812@outpost.ds9a.nl>
	<20060920132806.34eadc9e@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bert.hubert@netherlabs.nl, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:15075
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751392AbWIYDMa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Sep 2006 23:12:30 -0400
To: shemminger@osdl.org
In-Reply-To: <20060920132806.34eadc9e@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 20 Sep 2006 13:28:06 -0700

> Change how default TCP congestion control is chosen. Don't just use
> last installed module, instead allow selection during configuration,
> and make sure and use the default regardless of load order.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
