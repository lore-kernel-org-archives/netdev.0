From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] ipv6: separate out procfs code from mcast.c
Date: Tue, 23 Apr 2013 03:36:20 -0400 (EDT)
Message-ID: <20130423.033620.1101068519499870853.davem@davemloft.net>
References: <1366701302.21136.19.camel@cr0>
	<20130423.031805.544535198246859192.davem@davemloft.net>
	<1366702220.21136.23.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45370 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755402Ab3DWHgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 03:36:22 -0400
In-Reply-To: <1366702220.21136.23.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue, 23 Apr 2013 15:30:20 +0800

> This is hard to do, as in the email I replied to Stephen. So I
> prefer to just add a Kconfig dependency, at least for now.

A Kconfig hack is exactly what I've told you is an unacceptable
solution.
