From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SCTP: Fix kernel panic while received AUTH chunk with
 BAD shared key identifier
Date: Tue, 05 Feb 2008 03:03:17 -0800 (PST)
Message-ID: <20080205.030317.186200005.davem@davemloft.net>
References: <20080124121608.GA20633@hmsreliant.think-freely.org>
	<479A126F.4010505@hp.com>
	<47A81DBD.6000802@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37387
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756503AbYBELCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 06:02:49 -0500
In-Reply-To: <47A81DBD.6000802@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Tue, 05 Feb 2008 17:26:37 +0900

> If SCTP-AUTH is enabled, received AUTH chunk with BAD shared key 
> identifier will cause kernel panic.
 ...
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
