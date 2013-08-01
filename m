From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH v2] net/phy: micrel: Add OF configuration support
Date: Thu, 1 Aug 2013 08:03:33 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE015E4437@039-SN2MPN1-023.039d.mgd.msft.net>
References: <1375340034-23846-1-git-send-email-xobs@kosagi.com>
 <1375340034-23846-2-git-send-email-xobs@kosagi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Steven Rostedt <rostedt@goodmis.org>
To: Sean Cross <xobs@kosagi.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe005.messaging.microsoft.com ([216.32.180.188]:28871
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751651Ab3HAIDh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 04:03:37 -0400
In-Reply-To: <1375340034-23846-2-git-send-email-xobs@kosagi.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, August 1, 2013 at 2:54 PM, Sean Cross wrote:

> Some boards require custom PHY configuration, for example due to trace length differences. 
> Add the ability to configure these registers in order to get the PHY to function on boards that need it.
>
> Because PHYs are auto-detected based on MDIO device IDs, allow PHY configuration to be specified in the parent Ethernet device node
> if no PHY device node is present.
>
> Signed-off-by: Sean Cross <xobs@kosagi.com>

Acked-by: Fugang Duan <B38611@freescale.com>
