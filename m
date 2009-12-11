From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] cnic: Send delete command when shutting down iSCSI
 ring.
Date: Fri, 11 Dec 2009 15:17:08 -0800 (PST)
Message-ID: <20091211.151708.128120434.davem@davemloft.net>
References: <1260495658-25866-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40630
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761871AbZLKXRC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 18:17:02 -0500
In-Reply-To: <1260495658-25866-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 10 Dec 2009 17:40:57 -0800

> This step is necessary on the bnx2x devices when restarting the iSCSI
> ring.  Without it, the firmware can assert and cause bnx2x to report
> errors.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
