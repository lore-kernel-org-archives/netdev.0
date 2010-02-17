From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipmr: remove useless checks from ipmr_device_event
Date: Wed, 17 Feb 2010 13:51:01 -0800 (PST)
Message-ID: <20100217.135101.191183258.davem@davemloft.net>
References: <4B7BD0C4.3090304@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37721
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757548Ab0BQVuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 16:50:46 -0500
In-Reply-To: <4B7BD0C4.3090304@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 17 Feb 2010 14:19:32 +0300

> The net being checked there is dev_net(dev) and thus this if
> is always false.
> 
> Fits both net and net-next trees.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied to net-next-2.6
