From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] net/irda: convert bfin_sir to common Blackfin UART
 header
Date: Tue, 24 May 2011 01:13:21 -0400 (EDT)
Message-ID: <20110524.011321.2252896468896471520.davem@davemloft.net>
References: <201105232217.p4NMH9uH015477@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org, vapier@gentoo.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47009 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972Ab1EXFOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 01:14:49 -0400
In-Reply-To: <201105232217.p4NMH9uH015477@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 23 May 2011 15:17:09 -0700

> From: Mike Frysinger <vapier@gentoo.org>
> 
> No need to duplicate these defines now that the common Blackfin code has
> unified these for all UART devices.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> Cc: Samuel Ortiz <samuel@sortiz.org>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
