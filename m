From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6][NET-2.6.24] Make core networking code use
 seq_open_private
Date: Wed, 10 Oct 2007 02:32:59 -0700 (PDT)
Message-ID: <20071010.023259.21364277.davem@davemloft.net>
References: <470BA351.3070208@openvz.org>
	<470BA470.2010603@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54024
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752844AbXJJJc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 05:32:57 -0400
In-Reply-To: <470BA470.2010603@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 09 Oct 2007 19:55:28 +0400

> This concerns the ipv4 and ipv6 code mostly, but also the netlink
> and unix sockets.
> 
> The netlink code is an example of how to use the __seq_open_private()
> call - it saves the net namespace on this private.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
