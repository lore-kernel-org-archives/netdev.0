From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 0/8][IPIP]: Make IPIP tunnel work in net
 namespaces.
Date: Wed, 16 Apr 2008 01:08:17 -0700 (PDT)
Message-ID: <20080416.010817.198553785.davem@davemloft.net>
References: <48049E9C.1020207@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52768
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751875AbYDPIIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 04:08:16 -0400
In-Reply-To: <48049E9C.1020207@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 15 Apr 2008 16:25:00 +0400

> Make yet another useful virtual device work in namespaces.
> 
> This set is also isolated from the other "make xxx device work 
> in net namespaces" ones.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied and pushed to net-2.6.26, thanks Pavel.
