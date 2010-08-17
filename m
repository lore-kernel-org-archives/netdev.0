From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] am79c961a: Use net_device_stats from struct net_device
Date: Tue, 17 Aug 2010 02:35:06 -0700 (PDT)
Message-ID: <20100817.023506.112619831.davem@davemloft.net>
References: <1281366274-28796-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@arm.linux.org.uk, segooon@gmail.com
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34297
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932160Ab0HQJes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 05:34:48 -0400
In-Reply-To: <1281366274-28796-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Mon,  9 Aug 2010 17:04:34 +0200

> struct net_device has its own struct net_device_stats member, so we can
> use this one instead of a private copy in the dev_priv struct.
> 
> Cc: Kulikov Vasiliy <segooon@gmail.com>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
