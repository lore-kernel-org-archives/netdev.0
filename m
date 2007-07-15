From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv4: Cleanup call to __neigh_lookup()
Date: Sat, 14 Jul 2007 20:51:12 -0700 (PDT)
Message-ID: <20070714.205112.77404448.davem@davemloft.net>
References: <20070714221816.45c0ab9f@hyperion.delvare>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
To: khali@linux-fr.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36856
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752339AbXGODvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 23:51:09 -0400
In-Reply-To: <20070714221816.45c0ab9f@hyperion.delvare>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jean Delvare <khali@linux-fr.org>
Date: Sat, 14 Jul 2007 22:18:16 +0200

> Back in the times of Linux 2.2, negative values for the creat parameter
> of __neigh_lookup() had a particular meaning, but no longer, so we
> should pass 1 instead.
> 
> Signed-off-by: Jean Delvare <khali@linux-fr.org>

Applied, thanks.
