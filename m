From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 2/2] mlxsw: core: Trace EMAD messages
Date: Tue, 12 Jul 2016 14:20:35 -0700 (PDT)
Message-ID: <20160712.142035.953951390839427411.davem@davemloft.net>
References: <1468339504-27580-1-git-send-email-jiri@resnulli.us>
	<1468339504-27580-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	ivecera@redhat.com, rostedt@goodmis.org, mingo@redhat.com,
	jolsa@kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49600 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbcGLVUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 17:20:36 -0400
In-Reply-To: <1468339504-27580-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 12 Jul 2016 18:05:04 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Trace EMAD messages going down to HW and up from HW. Devlink needs to be
> registered before EMAD init so the trace function can be called
> with valid devlink handle.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> v1->v2:
> - Use trace_devlink_hwmsg directly

Applied.
