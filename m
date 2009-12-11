From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] cnic: Zero out status block and Event Queue
 indices.
Date: Fri, 11 Dec 2009 15:17:12 -0800 (PST)
Message-ID: <20091211.151712.116262012.davem@davemloft.net>
References: <1260495658-25866-1-git-send-email-mchan@broadcom.com>
	<1260495658-25866-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40633
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761722AbZLKXRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 18:17:06 -0500
In-Reply-To: <1260495658-25866-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 10 Dec 2009 17:40:58 -0800

> To prevent stale indices from causing spurious events when restarting the
> bnx2x devices.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
