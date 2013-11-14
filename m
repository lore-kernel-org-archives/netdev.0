From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] alx: Reset phy speed after resume
Date: Thu, 14 Nov 2013 17:15:21 -0500 (EST)
Message-ID: <20131114.171521.371758595511020967.davem@davemloft.net>
References: <1384445773.29057.5.camel@localhost.tld>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, chris.snook@gmail.com,
	johannes@sipsolutions.net, wangyijing@huawei.com,
	maarten.lankhorst@canonical.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux@hahnjo.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53406 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755273Ab3KNWPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 17:15:24 -0500
In-Reply-To: <1384445773.29057.5.camel@localhost.tld>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: hahnjo <linux@hahnjo.de>
Date: Thu, 14 Nov 2013 17:16:13 +0100

> From 27744b24f9291782c1342dbd6cac511e68da907c Mon Sep 17 00:00:00 2001
> From: hahnjo <hahnjo@hahnjo.de>
> Date: Tue, 12 Nov 2013 18:19:24 +0100
> Subject: [PATCH] alx: Reset phy speed after resume
> 
> This fixes bug 62491 (https://bugzilla.kernel.org/show_bug.cgi?id=62491).
> After resuming some users got the following error flooding the kernel log:
> alx 0000:02:00.0: invalid PHY speed/duplex: 0xffff
> 
> Signed-off-by: Jonas Hahnfeld <linux@hahnjo.de>

Applied, thanks.
