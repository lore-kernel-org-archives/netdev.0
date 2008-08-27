From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: mode 0555 in ipv4_skeleton
Date: Wed, 27 Aug 2008 02:35:26 -0700 (PDT)
Message-ID: <20080827.023526.246070710.davem@davemloft.net>
References: <Pine.LNX.4.64.0808261950390.4716@blonde.site>
	<20080826190639.GZ28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hugh@veritas.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42549
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753566AbYH0Jfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 05:35:31 -0400
In-Reply-To: <20080826190639.GZ28946@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Tue, 26 Aug 2008 20:06:39 +0100

> On Tue, Aug 26, 2008 at 08:00:03PM +0100, Hugh Dickins wrote:
> > vpnc on today's kernel says Cannot open "/proc/sys/net/ipv4/route/flush":
> > d--------- 0 root root 0 2008-08-26 11:32 /proc/sys/net/ipv4/route
> > d--------- 0 root root 0 2008-08-26 19:16 /proc/sys/net/ipv4/neigh
> > 
> > Signed-off-by: Hugh Dickins <hugh@veritas.com>
> 
> Acked-by: Al Viro <viro@zeniv.linux.org.uk>

Applied, thanks everyone.
