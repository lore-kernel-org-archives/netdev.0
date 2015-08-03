From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 2/2] rocker: linearize skb in case frags would
 not fit into tx descriptor
Date: Mon, 03 Aug 2015 14:22:39 -0700 (PDT)
Message-ID: <20150803.142239.1754691965012878975.davem@davemloft.net>
References: <1438541798-1725-1-git-send-email-jiri@resnulli.us>
	<1438541798-1725-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@gmail.com, idosch@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44955 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932193AbbHCVWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 17:22:40 -0400
In-Reply-To: <1438541798-1725-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sun,  2 Aug 2015 20:56:38 +0200

> Suggested-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied.
