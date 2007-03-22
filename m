From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [SCTP] Correctly reset ssthresh when restarting
 association
Date: Thu, 22 Mar 2007 12:26:40 -0700 (PDT)
Message-ID: <20070322.122640.28798927.davem@davemloft.net>
References: <4602D153.4000201@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33754
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933999AbXCVT0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 15:26:40 -0400
In-Reply-To: <4602D153.4000201@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu, 22 Mar 2007 14:56:19 -0400

> Reset ssthresh to the correct value (peer's a_rwnd) when restarting
> association.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied, thanks Vlad.
