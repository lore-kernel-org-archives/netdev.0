From: David Miller <davem@davemloft.net>
Subject: Re: net: fix packet socket delivery in rx irq handler
Date: Tue, 04 Nov 2008 14:50:05 -0800 (PST)
Message-ID: <20081104.145005.215858692.davem@davemloft.net>
References: <49104599.1030200@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50150
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756815AbYKDWu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 17:50:29 -0500
In-Reply-To: <49104599.1030200@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 04 Nov 2008 13:52:41 +0100

> This patch fixes the atl1 VLAN warning regression reported
> by Ramon Casellas.

Applied, thanks Patrick.
