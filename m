From: David Miller <davem@davemloft.net>
Subject: Re: [patch for 2.6.27? 2/2] drivers/net/netxen/netxen_nic_hw.c:
 fix printk warnings
Date: Thu, 31 Jul 2008 23:55:01 -0700 (PDT)
Message-ID: <20080731.235501.201774280.davem@davemloft.net>
References: <200807301950.m6UJoDY4013256@imap1.linux-foundation.org>
	<20080801061952.GI27241@verge.net.au>
	<20080731232809.470dd7d1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: horms@verge.net.au, jeff@garzik.org, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52213
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752810AbYHAGzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 02:55:01 -0400
In-Reply-To: <20080731232809.470dd7d1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 31 Jul 2008 23:28:09 -0700

> I wonder who was the first 64-bit bright spark who decided to use `long'.

/me hides :)
