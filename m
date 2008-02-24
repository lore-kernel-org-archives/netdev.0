From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3][BNX2]: Disable parallel detect on an HP blade.
Date: Sat, 23 Feb 2008 19:49:17 -0800 (PST)
Message-ID: <20080223.194917.04295371.davem@davemloft.net>
References: <1203709811.13495.178.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57665
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752394AbYBXDsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 22:48:36 -0500
In-Reply-To: <1203709811.13495.178.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 22 Feb 2008 11:50:11 -0800

> [BNX2]: Disable parallel detect on an HP blade.
> 
> Because of some board issues, we need to disable parallel detect on
> an HP blade.  Without this patch, the link state can become stuck
> when it goes into parallel detect mode.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
