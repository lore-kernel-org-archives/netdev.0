From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/9] Consolidate the xxx_put
Date: Mon, 15 Oct 2007 02:42:05 -0700 (PDT)
Message-ID: <20071015.024205.68142097.davem@davemloft.net>
References: <470F6EAE.60308@openvz.org>
	<470F769D.8000501@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39923
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758039AbXJOJmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 05:42:01 -0400
In-Reply-To: <470F769D.8000501@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 12 Oct 2007 17:29:01 +0400

> These ones use the generic data types too, so move
> them in one place.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Also applied, thanks!
