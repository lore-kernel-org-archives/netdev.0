From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Remove unneeded pointer newdp from
 dccp_v4_request_recv_sock() in net/dccp/ipv4.c
Date: Wed, 05 Sep 2007 07:58:44 -0700 (PDT)
Message-ID: <20070905.075844.78727807.davem@davemloft.net>
References: <46DE42D9.2040200@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: micah.gruber@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:54314
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756692AbXIEPUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2007 11:20:48 -0400
In-Reply-To: <46DE42D9.2040200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Micah Gruber <micah.gruber@gmail.com>
Date: Wed, 05 Sep 2007 13:47:05 +0800

> This trivial patch removes the unneeded pointer newdp, which is never used.
> 
> Signed-off-by: Micah Gruber <micah.gruber@gmail.com>

Applied, thanks.
