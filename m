From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v6 0/5] sctp: Patch series
Date: Tue, 26 Apr 2011 00:12:47 -0700 (PDT)
Message-ID: <20110426.001247.39188691.davem@davemloft.net>
References: <28B01B73-1E94-4E0A-BA9B-82122A6726E4@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: micchie@sfc.wide.ad.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44207
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757728Ab1DZHNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 03:13:20 -0400
In-Reply-To: <28B01B73-1E94-4E0A-BA9B-82122A6726E4@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michio Honda <micchie@sfc.wide.ad.jp>
Date: Tue, 26 Apr 2011 13:28:40 +0900

> Series of 5 patches to support auto_asconf and the other related functionalities that auto_asconf relies on. 
> 
> Cheers,
> - Michio
> 
> [1/5] Add Auto-ASCONF support
> [2/5] Add sysctl support for Auto-ASCONF
> [3/5] Add socket option operation for Auto-ASCONF
> [4/5] Add ADD/DEL ASCONF handling at the receiver
> [5/5] Add ASCONF operation on the single-homed host--

Series applied.
