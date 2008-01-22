From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SCTP: Fix kernel panic while received AUTH chunk with
 BAD shared key identifier
Date: Tue, 22 Jan 2008 06:17:56 -0800 (PST)
Message-ID: <20080122.061756.263960428.davem@davemloft.net>
References: <4795A960.7000700@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	vladislav.yasevich@hp.com
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59797
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751426AbYAVORt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 09:17:49 -0500
In-Reply-To: <4795A960.7000700@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Tue, 22 Jan 2008 17:29:20 +0900

> If SCTP-AUTH is enabled, received AUTH chunk with BAD shared key 
> identifier will cause kernel panic.

Vlad, please review this.

Thanks.
