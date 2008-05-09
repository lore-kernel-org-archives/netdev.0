From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next-2.6 2/3] [SCTP]: Support the new specification of
 sctp_connectx()
Date: Fri, 09 May 2008 15:15:09 -0700 (PDT)
Message-ID: <20080509.151509.02016793.davem@davemloft.net>
References: <1210360481-16599-1-git-send-email-vladislav.yasevich@hp.com>
	<1210360566-16661-2-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42493
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756403AbYEIWPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 18:15:14 -0400
In-Reply-To: <1210360566-16661-2-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri,  9 May 2008 15:16:05 -0400

> The specification of sctp_connectx() has been changed to return
> an association id.  We've added a new socket option that will
> return the association id as the return value from the setsockopt()
> call.  The library that implements sctp_connectx() interface will
> implement both socket options.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
