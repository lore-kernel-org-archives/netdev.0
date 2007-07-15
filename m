From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: tcp probe add back ssthresh field
Date: Sat, 14 Jul 2007 18:57:39 -0700 (PDT)
Message-ID: <20070714.185739.85418071.davem@davemloft.net>
References: <20070711105115.43ae0530@freepuppy.rosehill.hemminger.net>
	<20070711.194402.32095330.davem@davemloft.net>
	<20070712124511.56f7cc3a@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33299
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759635AbXGOB5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 21:57:37 -0400
In-Reply-To: <20070712124511.56f7cc3a@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 12 Jul 2007 12:45:11 -0700

> Sangtae noticed the ssthresh got missed.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied, thanks Stephen.
