From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] sunvnet: add SG, HW_CSUM, GSO, and TSO
 support
Date: Mon, 08 Dec 2014 21:19:40 -0500 (EST)
Message-ID: <20141208.211940.1298960161172381337.davem@davemloft.net>
References: <547E216F.4000307@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59410 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbaLICTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 21:19:42 -0500
In-Reply-To: <547E216F.4000307@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Tue, 02 Dec 2014 15:30:39 -0500

> This patch set adds everything needed for TSO support in sunvnet. On my
> test hardware, this increases the single-stream TCP throughput for the
> default 1500-byte MTU Linux-Linux from ~2Gbps to 10Gbps and Linux-Solaris
> from ~2Gbps to 6Gbps.

Looks great, series applied, thanks!
