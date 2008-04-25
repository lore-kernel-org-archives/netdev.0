From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix typo in net/ipv6/Kconfig
Date: Thu, 24 Apr 2008 23:50:43 -0700 (PDT)
Message-ID: <20080424.235043.152016786.davem@davemloft.net>
References: <20080424084009.61f773a6@snafu.setup>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: youvegotmoxie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59096
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756191AbYDYGun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 02:50:43 -0400
In-Reply-To: <20080424084009.61f773a6@snafu.setup>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Beasley <youvegotmoxie@gmail.com>
Date: Thu, 24 Apr 2008 08:40:09 -0400

> From: Michael Beasley <youvegotmoxie@gmail.com>
> 
> Two is used in the wrong context here, as you are connecting to an IPv6 network
> over IPv4; not connecting two IPv6 networks to an IPv4 one.
> 
> Signed-off-by: Michael Beasley <youvegotmoxie@gmail.com>

Applied, thanks Michael.
