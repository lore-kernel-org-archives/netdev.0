From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v3 0/3] sctp: Patch series
Date: Sun, 10 Apr 2011 18:52:36 -0700 (PDT)
Message-ID: <20110410.185236.59685173.davem@davemloft.net>
References: <DF0CDFCF-8559-495A-9C9E-60997E7DE0F2@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: micchie@sfc.wide.ad.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51664
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752884Ab1DKBxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2011 21:53:12 -0400
In-Reply-To: <DF0CDFCF-8559-495A-9C9E-60997E7DE0F2@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michio Honda <micchie@sfc.wide.ad.jp>
Date: Fri, 8 Apr 2011 14:18:30 +0900

[ Changed lksctp to linux-sctp@vger.kernel.org as that is the mailing
  list provided in linux/MAINTAINERS ]

> Series of 5 patches to support auto_asconf and the other related
> functionalities that auto_asconf relies on.
...
> [1/3] Add Auto-ASCONF support
> [2/3] Add ASCONF operation on the single-homed host
> [3/3] Add a valid address list in association local

Can an SCTP expert please review these patches?
