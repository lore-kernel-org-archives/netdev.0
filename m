From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SCTP: Fix chunk parameter processing bug
Date: Wed, 05 Mar 2008 13:44:13 -0800 (PST)
Message-ID: <20080305.134413.234972395.davem@davemloft.net>
References: <47CE474B.3040709@cn.fujitsu.com>
	<47CEA5E9.80202@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: guijianfeng@cn.fujitsu.com, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54952
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762487AbYCEVoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 16:44:16 -0500
In-Reply-To: <47CEA5E9.80202@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 05 Mar 2008 08:53:45 -0500

> Gui Jianfeng wrote:
> > Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
> 
> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> 
> Thanks for catching this.

I applied this after killing trailing whitespace errors and making the
added comment conform to kernel coding standards.

Thanks.
