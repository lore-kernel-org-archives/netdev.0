From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net/sched/sch_teql.c] duplicate IFF_BROADCAST in
 FMASK, remove 2nd
Date: Thu, 31 Jan 2008 17:08:59 -0800 (PST)
Message-ID: <20080131.170859.188828281.davem@davemloft.net>
References: <47A08B7C.9010205@tiscali.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: 12o3l@tiscali.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52670
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751324AbYBABIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 20:08:38 -0500
In-Reply-To: <47A08B7C.9010205@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <12o3l@tiscali.nl>
Date: Wed, 30 Jan 2008 15:36:44 +0100

> Untested patch below, please confirm it's the right fix (should it be some
> other IFF_*?)
> --
> duplicate IFF_BROADCAST, remove 2nd
> 
> Signed-off-by: Roel Kluin <12o3l@tiscali.nl>

Applied, thanks.
