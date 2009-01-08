From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/42] appletalk: convert ipddp to net_device_ops
Date: Wed, 07 Jan 2009 17:22:47 -0800 (PST)
Message-ID: <20090107.172247.152425486.davem@davemloft.net>
References: <20090107003316.784424362@vyatta.com>
	<20090107003345.633563939@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36708
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754971AbZAHBWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 20:22:45 -0500
In-Reply-To: <20090107003345.633563939@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 06 Jan 2009 16:33:18 -0800

> Use internal element in network device for stats as well.

Tsk tsk, combining two seperate changes into one patch
submission...

> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
