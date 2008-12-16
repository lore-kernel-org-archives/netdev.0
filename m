From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.29] cxgb3 - untie strict FW matching
Date: Tue, 16 Dec 2008 01:51:57 -0800 (PST)
Message-ID: <20081216.015157.101673618.davem@davemloft.net>
References: <20081215191338.22028.66965.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56410
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752038AbYLPJv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 04:51:56 -0500
In-Reply-To: <20081215191338.22028.66965.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Mon, 15 Dec 2008 11:13:38 -0800

> The NIC driver can work with mutliple versions of the FW.
> Let the driver load when the embedded FW does not match,
> and the FW update mechanism failed.
> The iWARP module will make its own loading decision.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied, thanks Divy.
