From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cris/eth_v10: Use net_device_stats from struct
 net_device_stats
Date: Mon, 06 Dec 2010 13:25:23 -0800 (PST)
Message-ID: <20101206.132523.115937711.davem@davemloft.net>
References: <1291310525-6101-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, starvik@axis.com, jesper.nilsson@axis.com
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40193
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753500Ab0LFVY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 16:24:56 -0500
In-Reply-To: <1291310525-6101-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Thu,  2 Dec 2010 18:22:05 +0100

> struct net_device has its own struct net_device_stats member, so use
> this one instead of a private copy in struct net_local.
> 
> Note: This patch was not even compile tested.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
