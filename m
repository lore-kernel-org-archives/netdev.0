From: David Miller <davem@davemloft.net>
Subject: Re: [VLAN 00/18]: Vlan update
Date: Mon, 21 Jan 2008 00:34:06 -0800 (PST)
Message-ID: <20080121.003406.162149599.davem@davemloft.net>
References: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43640
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758125AbYAUIeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 03:34:00 -0500
In-Reply-To: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Sun, 20 Jan 2008 18:11:17 +0100 (MET)

> the following patches contain a VLAN update for 2.6.25, consisting mainly
> of minor cleanups removing duplicate code, avoiding forward declarations,
> makeing functions static etc. Next I'll look into the skb->cb issues
> with VLAN.
> 
> Please apply, thanks.

All applied, thanks.

I wasn't thrilled to see MAC_FMT return, but then again I could
not recommend a better alternative :-)
