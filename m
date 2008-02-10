From: David Miller <davem@davemloft.net>
Subject: Re: [PKT_SCHED] deinline functions in meta match
Date: Sat, 09 Feb 2008 23:26:28 -0800 (PST)
Message-ID: <20080209.232628.39933381.davem@davemloft.net>
References: <20080208095557.15cee30f@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33582
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759543AbYBJHZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2008 02:25:56 -0500
In-Reply-To: <20080208095557.15cee30f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 8 Feb 2008 09:55:57 -0800

> A couple of functions in meta match don't need to be inline.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
