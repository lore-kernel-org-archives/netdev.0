From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: cdg: use div_u64()
Date: Sun, 14 Jun 2015 12:58:09 -0700 (PDT)
Message-ID: <20150614.125809.1619929910575307463.davem@davemloft.net>
References: <1434122643-16330-1-git-send-email-kennetkl@ifi.uio.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kennetkl@ifi.uio.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33355 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024AbbFNT6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2015 15:58:10 -0400
In-Reply-To: <1434122643-16330-1-git-send-email-kennetkl@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Date: Fri, 12 Jun 2015 17:24:03 +0200

> Fixes cross-compile to mips.
> 
> Signed-off-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>

Applied, thanks.
