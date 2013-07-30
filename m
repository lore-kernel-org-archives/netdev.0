From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 0/2] net: mvneta: big endian support
Date: Tue, 30 Jul 2013 16:51:33 -0700 (PDT)
Message-ID: <20130730.165133.957470552413947516.davem@davemloft.net>
References: <1375104088-24654-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	ezequiel.garcia@free-electrons.com,
	gregory.clement@free-electrons.com, alior@marvell.com
To: thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43653 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755837Ab3G3Xve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 19:51:34 -0400
In-Reply-To: <1375104088-24654-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Mon, 29 Jul 2013 15:21:26 +0200

> You'll find in this patch series two small patches that add support
> for big-endian in the mvneta driver, for the network interface found
> in ARM Marvell Armada 370 and Armada XP SOCs. They are based on
> 3.11-rc3.

Both applied to net-next, thanks.
