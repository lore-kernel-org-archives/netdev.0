From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: check return value for dst_alloc
Date: Tue, 27 Sep 2011 15:32:23 -0400 (EDT)
Message-ID: <20110927.153223.1456216895615936555.davem@davemloft.net>
References: <1317056696-23611-1-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, timo.teras@iki.fi
To: madalin.bucur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56165 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882Ab1I0Tcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 15:32:32 -0400
In-Reply-To: <1317056696-23611-1-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Madalin Bucur <madalin.bucur@freescale.com>
Date: Mon, 26 Sep 2011 20:04:56 +0300

> return value of dst_alloc must be checked before use
> 
> Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>

Applied.
