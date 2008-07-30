From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 - patch 1/1] ipv6 : Fix useless proc net sockstat6
 removal
Date: Wed, 30 Jul 2008 03:12:51 -0700 (PDT)
Message-ID: <20080730.031251.48779194.davem@davemloft.net>
References: <488E3D12.7010708@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33783
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761361AbYG3KMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 06:12:51 -0400
In-Reply-To: <488E3D12.7010708@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Mon, 28 Jul 2008 23:41:38 +0200

> ipv6: Fix useless proc net sockstat6 removal
> From: Daniel Lezcano <dlezcano@fr.ibm.com>
> 
> This call is no longer needed, sockstat6 is per namespace so it is
> removed at the namespace subsystem destruction.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Applied, thanks Daniel.
