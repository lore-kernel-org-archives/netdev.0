From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/8] "wrong timeout value in sk_wait_data()": cleanups
Date: Mon, 09 Jul 2007 13:16:08 -0700 (PDT)
Message-ID: <20070709.131608.84975018.davem@davemloft.net>
References: <200707091851.l69IpBFV001731@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vvs@sw.ru
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46048
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753308AbXGIUPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 16:15:46 -0400
In-Reply-To: <200707091851.l69IpBFV001731@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Mon, 09 Jul 2007 11:51:10 -0700

> From: Andrew Morton <akpm@linux-foundation.org>
> 
> - save 4 bytes
> 
> - it's read-mostly.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Acked-by: Vasily Averin <vvs@sw.ru>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
