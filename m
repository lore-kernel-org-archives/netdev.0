From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: fix errata in show results
Date: Mon, 07 Mar 2011 01:19:42 -0800 (PST)
Message-ID: <20110307.011942.115928916.davem@davemloft.net>
References: <4D74A0D7.3020506@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ljw@handong.edu, robert@herjulf.net
To: daniel.turull@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46657
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752201Ab1CGJTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 04:19:06 -0500
In-Reply-To: <4D74A0D7.3020506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Turull <daniel.turull@gmail.com>
Date: Mon, 07 Mar 2011 10:09:43 +0100

> The units in show_results in pktgen were not correct.
> The results are in usec but it was displayed nsec.
> 
> Reported-by: Jong-won Lee <ljw@handong.edu>
> Signed-off-by: Daniel Turull <daniel.turull@gmail.com>
> ---

Your email client corrupted the patch.
