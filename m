From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 1/2] rocker: enable support for scattered
 packets
Date: Mon, 03 Aug 2015 14:22:34 -0700 (PDT)
Message-ID: <20150803.142234.2026273899360655895.davem@davemloft.net>
References: <1438541798-1725-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@gmail.com, idosch@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44950 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932193AbbHCVWf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 17:22:35 -0400
In-Reply-To: <1438541798-1725-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sun,  2 Aug 2015 20:56:37 +0200

> From: Ido Schimmel <idosch@mellanox.com>
> 
> rocker supports the transmission of scattered packets, so let the kernel
> know about it by setting the NETIF_F_SG bit in the device's features.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied.
