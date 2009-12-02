From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2] net/ps3: Cleanup gelic enums
Date: Wed, 02 Dec 2009 00:53:27 -0800 (PST)
Message-ID: <20091202.005327.142907680.davem@davemloft.net>
References: <4B159599.1010208@am.sony.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: geoffrey.levand@am.sony.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44317
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754881AbZLBIxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 03:53:21 -0500
In-Reply-To: <4B159599.1010208@am.sony.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geoff Levand <geoffrey.levand@am.sony.com>
Date: Tue, 1 Dec 2009 14:15:53 -0800

> Cleanup of the gelic driver enumerations:
> 
>  o Add some missing commas.
>  o Add an Ether port post fix (PS3 currently only supports PORT_0).
>  o Add a new enum gelic_lv1_phy to use when interacting with the PHY.
> 
> Signed-off-by: Geoff Levand <geoffrey.levand@am.sony.com>
> ---
> Hi Jeff,
> 
> This patch does some cleanup needed by the 2nd patch
> [patch 2/2] net/ps3: Add support for gelic link negotiation.
> 
> Please apply for 2.3.33.

Jeff hasn't handled networking driver patches for more than a year.
Please CC: me instead.

Both patches applied to net-next-2.6, thanks.
