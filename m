From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] iproute2: Add new command to IP link to
 enable/disable VF spoof check
Date: Mon, 26 Sep 2011 17:27:02 -0400 (EDT)
Message-ID: <20110926.172702.400522716452242592.davem@davemloft.net>
References: <184D23435BECB444AB6B9D4630C8EC83028F8A71@XMB-RCD-303.cisco.com>
	<20110926.170049.1943390151354224651.davem@davemloft.net>
	<20110926141959.58d310c0@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benve@cisco.com, bhutchings@solarflare.com,
	gregory.v.rose@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60387 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859Ab1IZV1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 17:27:12 -0400
In-Reply-To: <20110926141959.58d310c0@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 26 Sep 2011 14:19:59 -0700

> If an interface changes before an official release, there is no
> problem. I.e. if an interface goes through multiple versions while
> in net-next (or a bug fix during 3.X-rc*) that's fine.

Right.
