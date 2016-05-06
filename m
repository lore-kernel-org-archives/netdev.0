From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] mlxsw: spectrum: Fix ordering in mlxsw_sp_fini
Date: Fri, 06 May 2016 19:00:31 -0400 (EDT)
Message-ID: <20160506.190031.422450384072355310.davem@davemloft.net>
References: <1462566059-2128-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51857 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756722AbcEGABv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 20:01:51 -0400
In-Reply-To: <1462566059-2128-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri,  6 May 2016 22:20:59 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Fixes: 0f433fa0ec ("mlxsw: spectrum_buffers: Implement shared buffer configuration")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
