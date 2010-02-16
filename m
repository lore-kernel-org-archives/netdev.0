From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 4/6] bnx2: Allow user-specified multiple
 advertisement speed values.
Date: Tue, 16 Feb 2010 15:20:30 -0800 (PST)
Message-ID: <20100216.152030.94724176.davem@davemloft.net>
References: <1266298932-28129-2-git-send-email-mchan@broadcom.com>
	<1266298932-28129-3-git-send-email-mchan@broadcom.com>
	<1266298932-28129-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32840
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933354Ab0BPXUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 18:20:14 -0500
In-Reply-To: <1266298932-28129-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 15 Feb 2010 21:42:10 -0800

> Remove unnecessary code that works around older versions of ethtool
> that can pass down invalid advertisement speed values.  This old
> code prevents the user from specifying multiple advertisement values.
> The new code uses simple masking to mask out invalid advertisment bits.
> 
> Reported-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>

Applied.
