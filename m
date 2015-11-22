From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: l3mdev: Add master device lookup by
 index
Date: Sun, 22 Nov 2015 13:17:15 -0500 (EST)
Message-ID: <20151122.131715.1858345389016284808.davem@davemloft.net>
References: <1447965121-2345-1-git-send-email-dsa@cumulusnetworks.com>
	<20151122.122359.2247708943529789130.davem@davemloft.net>
	<5651FBB8.6030008@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40768 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751735AbbKVSRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 13:17:23 -0500
In-Reply-To: <5651FBB8.6030008@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sun, 22 Nov 2015 10:30:32 -0700

> In this case ...

I understand the problem you are trying to solve, but I am saying
you can't use sk_bound_dev_if to use it.
