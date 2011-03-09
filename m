From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: fix errata in show results
Date: Wed, 09 Mar 2011 14:11:09 -0800 (PST)
Message-ID: <20110309.141109.229750104.davem@davemloft.net>
References: <4D74A0D7.3020506@gmail.com>
	<20110307.011942.115928916.davem@davemloft.net>
	<4D74A908.7040302@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ljw@handong.edu, robert@herjulf.net
To: daniel.turull@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60875
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753314Ab1CIWKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 17:10:32 -0500
In-Reply-To: <4D74A908.7040302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Turull <daniel.turull@gmail.com>
Date: Mon, 07 Mar 2011 10:44:40 +0100

> The units in show_results in pktgen were not correct.
> The results are in usec but it was displayed nsec.
> 
> Reported-by: Jong-won Lee <ljw@handong.edu>
> Signed-off-by: Daniel Turull <daniel.turull@gmail.com>

Applied, thanks.
