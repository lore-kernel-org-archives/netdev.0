From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable outer Tx checksum by
 default
Date: Tue, 23 Feb 2016 18:11:59 -0500 (EST)
Message-ID: <20160223.181159.549163205159017607.davem@davemloft.net>
References: <56CC9914.5010506@solarflare.com>
	<20160223.130826.608797488173024832.davem@davemloft.net>
	<56CCBF22.6020904@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hpe.com, tom@herbertland.com, jesse@kernel.org,
	aduyck@mirantis.com, netdev@vger.kernel.org,
	alexander.duyck@gmail.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42113 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752564AbcBWXMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 18:12:19 -0500
In-Reply-To: <56CCBF22.6020904@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Tue, 23 Feb 2016 20:20:50 +0000

> So VJ implementations that can't handle it really are buggy, not
> just exhibiting a difference of opinion.

Buggy or not, they exist, and we have to cope with them.
