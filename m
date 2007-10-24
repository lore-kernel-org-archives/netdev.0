From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Consolidate sctp_ulpq_renege_xxx functions
Date: Tue, 23 Oct 2007 20:30:35 -0700 (PDT)
Message-ID: <20071023.203035.112623366.davem@davemloft.net>
References: <471E1082.8010607@openvz.org>
	<471E19F6.7020800@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, lksctp-developers@lists.sourceforge.net,
	netdev@vger.kernel.org, devel@openvz.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60115
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752909AbXJXDau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 23:30:50 -0400
In-Reply-To: <471E19F6.7020800@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Tue, 23 Oct 2007 11:57:42 -0400

> Pavel Emelyanov wrote:
> > Both are equal, except for the list to be traversed.
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> > 
> 
> ACK.  Good clean-up Pavel.

Yep, nice work, applied.

Thanks!
