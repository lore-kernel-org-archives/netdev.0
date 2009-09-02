From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] RTO connection timeout calculation
Date: Tue, 01 Sep 2009 17:45:22 -0700 (PDT)
Message-ID: <20090901.174522.20878161.davem@davemloft.net>
References: <4A9D82DC.50508@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: damian@tvk.rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40486
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755457AbZIBApI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 20:45:08 -0400
In-Reply-To: <4A9D82DC.50508@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Date: Tue, 01 Sep 2009 22:23:56 +0200

> this series of patches implements some changes concerning the RTO
> retransmission timeouts.
> 
> 1) retransmits_timed_out() is commented shortly and has
>    more meaningful names.
> 2) The sysctl documentation is being updated.
> 
> Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>

Looks good to me, all applied.

Thanks.
