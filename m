From: David Miller <davem@davemloft.net>
Subject: Re: [patch 4/4] mISDN: misc timerdev fixes
Date: Mon, 22 Sep 2008 19:18:26 -0700 (PDT)
Message-ID: <20080922.191826.16007223.davem@davemloft.net>
References: <200809222151.m8MLp3tb031906@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kkeil@suse.de, netdev@vger.kernel.org, andi@firstfloor.org,
	ak@linux.intel.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54430
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754033AbYIWCSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 22:18:38 -0400
In-Reply-To: <200809222151.m8MLp3tb031906@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 22 Sep 2008 14:51:03 -0700

> - Remove noop VFS stubs. The VFS does that on a NULL pointer anyways.
> - Fix timer handler prototype to be correct
> - Comment ugly SMP race I didn't fix.
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-next-2.6
