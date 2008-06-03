From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] IPV6: remove addresses and routes when carrier is
 lost
Date: Tue, 03 Jun 2008 10:31:20 -0700 (PDT)
Message-ID: <20080603.103120.231484333.davem@davemloft.net>
References: <20080603102144.571df55b@extreme>
	<20080603.102501.193702820.davem@davemloft.net>
	<48457F35.5060801@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54036
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753820AbYFCRbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 13:31:23 -0400
In-Reply-To: <48457F35.5060801@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 03 Jun 2008 19:28:21 +0200

> Maybe the logic to disable those routes should simply live in
> the routing daemons or a seperate daemon.

Indeed.
