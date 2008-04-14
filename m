From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26][SOCK]: Add some notes about per-bind-bucket
 sock lookup.
Date: Mon, 14 Apr 2008 02:42:49 -0700 (PDT)
Message-ID: <20080414.024249.29728674.davem@davemloft.net>
References: <48032662.30001@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38109
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750886AbYDNJmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 05:42:51 -0400
In-Reply-To: <48032662.30001@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 14 Apr 2008 13:39:46 +0400

> I was asked about "why don't we perform a sk_net filtering in
> bind_conflict calls, like we do in other sock lookup places"
> for a couple of times.
> 
> Can we please add a comment about why we do not need one?
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks Pavel.
