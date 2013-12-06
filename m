From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: SIOCGHWTSTAMP ioctl
Date: Thu, 05 Dec 2013 19:46:24 -0500 (EST)
Message-ID: <20131205.194624.1335606571649336470.davem@davemloft.net>
References: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org,
	richardcochran@gmail.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59991 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752426Ab3LFAq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 19:46:26 -0500
In-Reply-To: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 5 Dec 2013 23:37:12 +0000

> 1. Add the SIOCGHWTSTAMP ioctl and update the timestamping
> documentation.
> 2. Implement SIOCGHWTSTAMP in most drivers that support SIOCSHWTSTAMP.
> 3. Add a test program to exercise SIOC{G,S}HWTSTAMP.

Pulled, thanks Ben.
