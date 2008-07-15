From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/6] bnx2: Allow flexible VLAN tag settings.
Date: Mon, 14 Jul 2008 22:39:10 -0700 (PDT)
Message-ID: <20080714.223910.50889902.davem@davemloft.net>
References: <1215739755-5495-1-git-send-email-mchan@broadcom.com>
	<1215739755-5495-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46165
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753946AbYGOFjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 01:39:10 -0400
In-Reply-To: <1215739755-5495-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 10 Jul 2008 18:29:13 -0700

> Negotiate with boot code and ASF firmware to see if it can
> support keeping VLAN tags in the RX packets.  If supported
> by firmware, the VLAN tag will be kept in the RX packet
> unless VLAN acceleration is registered.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
