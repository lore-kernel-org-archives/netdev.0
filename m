From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH for 2.6.24] SCTP: Move sysctl_sctp_[rw]mem definitions
 to protocol.c
Date: Sun, 16 Sep 2007 16:05:25 -0700 (PDT)
Message-ID: <20070916.160525.35514716.davem@davemloft.net>
References: <46E9A5B1.5070202@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:45881
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752788AbXIPXFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 19:05:30 -0400
In-Reply-To: <46E9A5B1.5070202@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu, 13 Sep 2007 17:03:45 -0400

> The sctp_[rw]mem definitions should really be in protocol.c
> since that is where they are initialized.  This also allows
> one to build a kernel without sysctl support.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied to net-2.6.24, thanks Vlad.
