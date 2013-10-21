From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] ipv6: sit: Implement TSO/GSO support
Date: Mon, 21 Oct 2013 18:50:55 -0400 (EDT)
Message-ID: <20131021.185055.1323118406797986221.davem@davemloft.net>
References: <1382327251-21079-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hkchu@google.com, eilong@broadcom.com,
	ek@google.com, therbert@google.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44357 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490Ab3JUWu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 18:50:56 -0400
In-Reply-To: <1382327251-21079-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Sun, 20 Oct 2013 20:47:28 -0700

> This patch serie implements GSO/TSO support for SIT tunnels

Looks good, thanks for the descriptive cover posting it helps
a lot.

All applied to net-next.
