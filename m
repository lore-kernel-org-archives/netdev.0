From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] 3c515: Fix warning when building
Date: Tue, 29 Oct 2013 16:06:34 -0400 (EDT)
Message-ID: <20131029.160634.211135132113455855.davem@davemloft.net>
References: <1382738386-29888-1-git-send-email-ricec2@rpi.edu>
	<20131029.000316.767189982282205506.davem@davemloft.net>
	<1383075117.1534.23.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ricec2@rpi.edu, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48224 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583Ab3J2UGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 16:06:36 -0400
In-Reply-To: <1383075117.1534.23.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 29 Oct 2013 19:31:57 +0000

> Maybe the driver should just be deleted, as it doesn't look like it's
> actually usable any more.

I'd like to agree, however I think the last time we had this
discussion someone said they were still using such a device :-)
