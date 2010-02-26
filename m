From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/6] cnic: Use union for the status blocks of
 different devices.
Date: Fri, 26 Feb 2010 02:11:36 -0800 (PST)
Message-ID: <20100226.021136.251550197.davem@davemloft.net>
References: <1267058529-18454-3-git-send-email-mchan@broadcom.com>
	<1267058529-18454-4-git-send-email-mchan@broadcom.com>
	<1267058529-18454-5-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50683
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933219Ab0BZKLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 05:11:18 -0500
In-Reply-To: <1267058529-18454-5-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 24 Feb 2010 16:42:08 -0800

> We only need to assign the status block address once and it also saves
> space in the structure.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Eddie Wai <waie@broadcom.com>

Applied.
