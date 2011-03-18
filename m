From: David Miller <davem@davemloft.net>
Subject: Re: LRO disable warnings on kernel 2.6.38
Date: Fri, 18 Mar 2011 12:59:55 -0700 (PDT)
Message-ID: <20110318.125955.02258226.davem@davemloft.net>
References: <20110318081524.42d18bd2@nehalam>
	<20110318.125221.212667543.davem@davemloft.net>
	<1300478286.2589.29.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, eric.dumazet@gmail.com, jdb@comx.dk,
	netdev@vger.kernel.org, nhorman@tuxdriver.com,
	alexander.h.duyck@intel.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35794
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756760Ab1CRT7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 15:59:17 -0400
In-Reply-To: <1300478286.2589.29.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 18 Mar 2011 19:58:06 +0000

> You mean like netdev_WARN()? :-)

Perfect, but it's be nice if we had a variant where the condition were
embedded into the macro as well.
