From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 2/3] mlxsw: expose EMAD transactions
 statistics via debugfs
Date: Tue, 25 Aug 2015 14:25:21 -0700 (PDT)
Message-ID: <20150825.142521.1764936130530564868.davem@davemloft.net>
References: <1440427547-8539-1-git-send-email-jiri@resnulli.us>
	<1440427547-8539-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com, jiri@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59771 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbbHYVZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 17:25:22 -0400
In-Reply-To: <1440427547-8539-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 24 Aug 2015 16:45:46 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Elad Raz <eladr@mellanox.com>

Enough with this debugfs madness.

Expose this stuff through standard interfaces.

They are simple statistics for crying out loud!

I'm not applying this, and I'm really getting irritated about how much
garbage people put into debugfs when it has _NO_ business being there.

Sorry.
