From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] 9p: client code cleanup
Date: Thu, 21 Oct 2010 04:32:13 -0700 (PDT)
Message-ID: <20101021.043213.220059264.davem@davemloft.net>
References: <20101019094816.7898beff@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ericvh@gmail.com, rminnich@sandia.gov, lucho@ionkov.net,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37633
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757602Ab0JULbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 07:31:51 -0400
In-Reply-To: <20101019094816.7898beff@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 19 Oct 2010 09:48:16 -0700

> Make p9_client_version static since only used in one file.
> Remove p9_client_auth because it is defined but never used.
> Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
