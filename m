From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] #if 0 sctp_update_copy_cksum()
Date: Fri, 26 Oct 2007 04:07:30 -0700 (PDT)
Message-ID: <20071026.040730.17032573.davem@davemloft.net>
References: <20071024162407.GD30533@stusta.de>
	<471FAB6A.4050204@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, sri@us.ibm.com,
	lksctp-developers@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50153
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750792AbXJZLH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 07:07:29 -0400
In-Reply-To: <471FAB6A.4050204@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 24 Oct 2007 16:30:34 -0400

> Adrian Bunk wrote:
> > sctp_update_copy_cksum() is no longer used.
> > 
> > Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ACK.

Applied, thanks!
