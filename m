From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 5/6] bnx2: Fix bug when saving statistics.
Date: Tue, 16 Feb 2010 15:20:42 -0800 (PST)
Message-ID: <20100216.152042.254202262.davem@davemloft.net>
References: <1266298932-28129-3-git-send-email-mchan@broadcom.com>
	<1266298932-28129-4-git-send-email-mchan@broadcom.com>
	<1266298932-28129-5-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32843
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933579Ab0BPXU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 18:20:27 -0500
In-Reply-To: <1266298932-28129-5-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 15 Feb 2010 21:42:11 -0800

> From: Patrick Rabau <pr2345@gmail.com>
> 
> This fixes the problem of dropping the carry when adding 2 32-bit values.
> Switch to use array indexing for better readability.
> 
> Reported by and fix provided by Patrick Rabau.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>

Applied.
