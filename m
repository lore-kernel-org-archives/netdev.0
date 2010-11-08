From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net dst: need linux/cache.h for
 ____cacheline_aligned_in_smp.
Date: Sun, 07 Nov 2010 19:58:20 -0800 (PST)
Message-ID: <20101107.195820.189706262.davem@davemloft.net>
References: <20101108035130.GA11477@linux-sh.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
To: lethal@linux-sh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43267
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752252Ab0KHD55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 22:57:57 -0500
In-Reply-To: <20101108035130.GA11477@linux-sh.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Mundt <lethal@linux-sh.org>
Date: Mon, 8 Nov 2010 12:51:30 +0900

> Presently the b43legacy build fails on an sh randconfig:
 ...
> Signed-off-by: Paul Mundt <lethal@linux-sh.org>

Applied, thanks Paul.
