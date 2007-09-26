From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] move hardware header functions out of netdevice
Date: Tue, 25 Sep 2007 19:24:28 -0700 (PDT)
Message-ID: <20070925.192428.18597166.davem@davemloft.net>
References: <20070824204310.388073598@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51188
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753967AbXIZCY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 22:24:28 -0400
In-Reply-To: <20070824204310.388073598@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 24 Aug 2007 13:43:10 -0700

> The follow patches series starts the process of moving function
> pointers out of network device structure. This saves space and
> separates code from data.
> 
> The first step is moving the functions dealing with hardware
> headers.
> 
> Patches are against current net-2.6.24 tree. Basic functional
> testing on ethernet part, not on all the other protocols affected.

Stephen, can you respin these against net-2.6.24 and resubmit?

Thanks!
