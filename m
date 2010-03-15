From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/5] atm: use for_each_set_bit()
Date: Mon, 15 Mar 2010 16:05:29 -0700 (PDT)
Message-ID: <20100315.160529.213468438.davem@davemloft.net>
References: <201003112207.o2BM7o2e013489@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akinobu.mita@gmail.com,
	chas@cmf.nrl.navy.mil
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42709
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S937057Ab0COXFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 19:05:07 -0400
In-Reply-To: <201003112207.o2BM7o2e013489@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Thu, 11 Mar 2010 14:07:50 -0800

> From: Akinobu Mita <akinobu.mita@gmail.com>
> 
> Replace open-coded loop with for_each_set_bit().
> 
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> Cc: Chas Williams <chas@cmf.nrl.navy.mil>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
