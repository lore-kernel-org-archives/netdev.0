From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Mon, 06 Apr 2009 19:07:45 -0700 (PDT)
Message-ID: <20090406.190745.263215778.davem@davemloft.net>
References: <20090406.175752.236260059.davem@davemloft.net>
	<alpine.LFD.2.00.0904061824410.4010@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44329
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751437AbZDGCH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 22:07:56 -0400
In-Reply-To: <alpine.LFD.2.00.0904061824410.4010@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 6 Apr 2009 18:25:31 -0700 (PDT)

> 
> 
> The sky2 driver is buggered (by the previous pull, I presume). Some PCI 
> interaction. NULL pointer dereference at boot.

Fixed in the PCI tree, have you pulled that one yet?
