From: David Miller <davem@davemloft.net>
Subject: Re: x25: Fix multiple buffer overruns/overreads
Date: Mon, 17 Oct 2011 19:32:05 -0400 (EDT)
Message-ID: <20111017.193205.1923132006595941667.davem@davemloft.net>
References: <1318653905-13716-1-git-send-email-mattjd@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	andrew.hendry@gmail.com
To: mattjd@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40579 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063Ab1JQXcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 19:32:09 -0400
In-Reply-To: <1318653905-13716-1-git-send-email-mattjd@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Daley <mattjd@gmail.com>
Date: Sat, 15 Oct 2011 00:45:02 -0400

> This patchset fixes several buffer overruns/overreads in the X.25
> packet layer. The first patch fixes a particularly nasty remote-triggerable
> buffer overflow, while the rest fix skb overreads on undersized/fragmented
> skbs.

All applied, thanks Matthew!
