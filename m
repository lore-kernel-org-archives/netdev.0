From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/3] drivers/atm: use time_before, time_before_eq, etc
Date: Sat, 19 Apr 2008 18:15:15 -0700 (PDT)
Message-ID: <20080419.181515.20270158.davem@davemloft.net>
References: <200804182046.m3IKkBpr014619@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, julia@diku.dk
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53060
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751774AbYDTBPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Apr 2008 21:15:13 -0400
In-Reply-To: <200804182046.m3IKkBpr014619@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Fri, 18 Apr 2008 13:46:10 -0700

> The functions time_before, time_before_eq, time_after, and time_after_eq
> are more robust for comparing jiffies against other values.
> 
> A simplified version of the semantic patch making this change is as follows:
> (http://www.emn.fr/x-info/coccinelle/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied, thanks.
