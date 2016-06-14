From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ipv6: fix checksum annotation in udp6_csum_init
Date: Tue, 14 Jun 2016 15:28:23 -0400 (EDT)
Message-ID: <20160614.152823.1843881981203700262.davem@davemloft.net>
References: <1465671401-6329-1-git-send-email-hannes@stressinduktion.org>
	<1465672537-26131-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49090 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388AbcFNT20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 15:28:26 -0400
In-Reply-To: <1465672537-26131-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 11 Jun 2016 21:15:37 +0200

> Cc: Tom Herbert <tom@herbertland.com>
> Fixes: 4068579e1e098fa ("net: Implmement RFC 6936 (zero RX csums for UDP/IPv6")
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
