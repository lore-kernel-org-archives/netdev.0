From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/7] drivers/bluetooth/bpa10x.c: fix memleak
Date: Tue, 05 Feb 2008 03:08:53 -0800 (PST)
Message-ID: <20080205.030853.197451259.davem@davemloft.net>
References: <200802050747.m157lv5j010452@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, netdev@vger.kernel.org, bunk@kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46098
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755886AbYBELIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 06:08:25 -0500
In-Reply-To: <200802050747.m157lv5j010452@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 04 Feb 2008 23:48:16 -0800

> From: Adrian Bunk <bunk@kernel.org>
> 
> This patch fixea a memleak spotted by the Coverity checker.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied, thanks.
