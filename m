From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/4] atl1c: WAKE_MCAST tested twice, not WAKE_UCAST
Date: Thu, 11 Jun 2009 02:34:46 -0700 (PDT)
Message-ID: <20090611.023446.49455217.davem@davemloft.net>
References: <200906101955.n5AJt3nD008241@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roel.kluin@gmail.com, csnook@redhat.com,
	jcliburn@gmail.com, jie.yang@atheros.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54281
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754639AbZFKJen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 05:34:43 -0400
In-Reply-To: <200906101955.n5AJt3nD008241@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 10 Jun 2009 12:55:03 -0700

> From: Roel Kluin <roel.kluin@gmail.com>
> 
> The WAKE_MCAST bit is tested twice, the first should be WAKE_UCAST.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> Cc: Jie Yang <jie.yang@atheros.com>
> Cc: Jay Cliburn <jcliburn@gmail.com>
> Cc: Chris Snook <csnook@redhat.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
