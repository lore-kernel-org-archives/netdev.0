From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/3] Minor IPv4 routing cleanups
Date: Tue, 29 Sep 2015 16:28:07 -0700 (PDT)
Message-ID: <20150929.162807.1724145382617490058.davem@davemloft.net>
References: <20150928175512.20320.97537.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60169 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbbI2X2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 19:28:08 -0400
In-Reply-To: <20150928175512.20320.97537.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Mon, 28 Sep 2015 11:10:25 -0700

> These patches just contain some minor cleanups to address a few minor
> issues.  The first and the third mostly just improve readability.  The
> second patch should improve the performance for multicast destination
> addresses that do not have a localhost source IP address by avoiding some
> unnecessary dereferences.

Series applied, thanks.
