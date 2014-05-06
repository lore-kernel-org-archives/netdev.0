From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/24] net, diet: Make ethtool optional
Date: Mon, 05 May 2014 23:22:31 -0400 (EDT)
Message-ID: <20140505.232231.1253667586982376120.davem@davemloft.net>
References: <1399328773-6531-10-git-send-email-andi@firstfloor.org>
	<20140505.231140.2172378266544060318.davem@davemloft.net>
	<20140506031412.GN2382@two.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36016 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933809AbaEFDWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 23:22:33 -0400
In-Reply-To: <20140506031412.GN2382@two.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Tue, 6 May 2014 05:14:12 +0200

> You can configure the IP address and transmit and receive packets,
> and that is all a small embedded system is ever interested in.

Then let's agree to disagree, I am absolutely certain that small
systems are interested in much more than just these simple
configuration operations.
