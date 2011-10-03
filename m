From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] bridge: allow updating existing fdb entries
Date: Mon, 03 Oct 2011 12:18:43 -0400 (EDT)
Message-ID: <20111003.121843.197010181791293319.davem@davemloft.net>
References: <20111001003725.449204345@vyatta.com>
	<20111001003835.411004527@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42877 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980Ab1JCQSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 12:18:46 -0400
In-Reply-To: <20111001003835.411004527@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 30 Sep 2011 17:37:27 -0700

> Need to allow application to update existing fdb entries that already
> exist. This makes bridge netlink neighbor API have same flags and
> semantics as ip neighbor table.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
