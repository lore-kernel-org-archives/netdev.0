From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] openvswitch: Add support for checksums on UDP
 tunnels.
Date: Wed, 28 Jan 2015 23:04:28 -0800 (PST)
Message-ID: <20150128.230428.986343026110615674.davem@davemloft.net>
References: <1422491566-80453-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org, dev@openvswitch.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36727 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbbA2HEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 02:04:30 -0500
In-Reply-To: <1422491566-80453-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Wed, 28 Jan 2015 16:32:46 -0800

> Currently, it isn't possible to request checksums on the outer UDP
> header of tunnels - the TUNNEL_CSUM flag is ignored. This adds
> support for requesting that UDP checksums be computed on transmit
> and properly reported if they are present on receive.
> 
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied.
