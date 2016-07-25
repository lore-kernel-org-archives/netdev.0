From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 0/9] mlxsw: implement port mirroring offload
Date: Sun, 24 Jul 2016 23:12:28 -0700 (PDT)
Message-ID: <20160724.231228.1328289977464867937.davem@davemloft.net>
References: <1469095397-3837-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yotamg@mellanox.com, eladr@mellanox.com,
	idosch@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	jhs@mojatatu.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59200 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861AbcGYGMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 02:12:32 -0400
In-Reply-To: <1469095397-3837-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 21 Jul 2016 12:03:08 +0200

> This patchset introduces tc matchall classifier and its offload to
> Spectrum hardware. In combination with mirred action, defined port
> mirroring setup is offloaded by mlxsw/spectrum driver.

Series applied, thanks Jiri.
