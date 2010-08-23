From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix deadlock between boomerang_interrupt and
 boomerang_start_tx in 3c59x
Date: Mon, 23 Aug 2010 12:38:05 -0700 (PDT)
Message-ID: <20100823.123805.214238092.davem@davemloft.net>
References: <1281538818-3915-1-git-send-email-nhorman@tuxdriver.com>
	<20100811.231334.39172883.davem@davemloft.net>
	<20100823183227.GB12906@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56936
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753026Ab0HWThs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 15:37:48 -0400
In-Reply-To: <20100823183227.GB12906@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 23 Aug 2010 14:32:27 -0400

> Dave, any further thoughts here?  Is the explination regarding the lack of
> lock-race satisfactory, or would you rather we just pull all the pr_* calls from
> the interrupt handler?

Sorry, I have your most recently reply in my inbox and haven't looked into
it yet, will try to do so today.
