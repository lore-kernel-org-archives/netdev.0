From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sctp: Correctly cleanup procfs entries upon
 failure.
Date: Mon, 16 Jun 2008 17:01:10 -0700 (PDT)
Message-ID: <20080616.170110.253786385.davem@davemloft.net>
References: <1213364949-9997-1-git-send-email-vladislav.yasevich@hp.com>
	<1213364949-9997-2-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, yjwei@cn.fujitsu.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45241
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750793AbYFQABK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 20:01:10 -0400
In-Reply-To: <1213364949-9997-2-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 13 Jun 2008 09:49:08 -0400

> This patch remove the proc fs entry which has been created if fail to
> set up proc fs entry for the SCTP protocol.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied to net-2.6
