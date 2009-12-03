From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] bnx2: Protect tx timeout reset with rtnl_lock().
Date: Thu, 03 Dec 2009 13:07:50 -0800 (PST)
Message-ID: <20091203.130750.264371142.davem@davemloft.net>
References: <1259869595-6450-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57234
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751689AbZLCVHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 16:07:45 -0500
In-Reply-To: <1259869595-6450-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 3 Dec 2009 11:46:31 -0800

> To prevent race conditions with other reset events.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
