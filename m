From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] More device type integration
Date: Mon, 05 Oct 2009 00:44:43 -0700 (PDT)
Message-ID: <20091005.004443.242266867.davem@davemloft.net>
References: <cover.1254495724.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net, greg@kroah.com
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40154
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758604AbZJEHos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 03:44:48 -0400
In-Reply-To: <cover.1254495724.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Fri,  2 Oct 2009 17:15:24 +0200

> I followed the work from Johannes and made sure we can register the
> device type for wireless devices via the netdev notifier callback for
> all cfg80211 based devices. This way we don't have to touch any of
> the drivers.
> 
> For the mobile broadband cards from Ericsson, the device type is now
> set to "wwan" and it also uses "wwan%d" for the default interface name.

Looks good, all applied to net-next-2.6

Thanks!
