From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: add clock gating feature <resend>
Date: Fri, 01 May 2009 15:30:55 -0700 (PDT)
Message-ID: <20090501.153055.114295429.davem@davemloft.net>
References: <49FADFFE.7020300@nvidia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, akpm@osdl.org, netdev@vger.kernel.org
To: aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41917
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757754AbZEAWbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 18:31:01 -0400
In-Reply-To: <49FADFFE.7020300@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayaz Abdulla <aabdulla@nvidia.com>
Date: Fri, 01 May 2009 07:41:50 -0400

> This patch adds new logic to support a clock gating feature found on
> the latest set of chipsets. The clock gating is performed on the tx/rx
> engines when the link is disconnected. Clock gating helps in reducing
> power consumption.
> 
> * modified based on comments from netdev
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

Applied to net-next-2.6, thanks.
