From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: fix checksum annotation in udp4_csum_init
Date: Tue, 14 Jun 2016 15:28:44 -0400 (EDT)
Message-ID: <20160614.152844.1205432039009601156.davem@davemloft.net>
References: <1465725766-14474-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	tom@herbertland.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49098 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388AbcFNT2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 15:28:45 -0400
In-Reply-To: <1465725766-14474-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sun, 12 Jun 2016 12:02:46 +0200

> Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
> Cc: Cong Wang <xiyou.wangcong@gmail.com>
> Cc: Tom Herbert <tom@herbertland.com>
> Fixes: 4068579e1e098fa ("net: Implmement RFC 6936 (zero RX csums for UDP/IPv6")
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
