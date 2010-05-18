From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/9] netdev: bfin_mac: check for mii_bus platform data
Date: Mon, 17 May 2010 17:22:12 -0700 (PDT)
Message-ID: <20100517.172212.245392589.davem@davemloft.net>
References: <1273505954-32588-1-git-send-email-vapier@gentoo.org>
	<1273505954-32588-9-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	sonic.zhang@analog.com
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43067
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755980Ab0ERAWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 20:22:03 -0400
In-Reply-To: <1273505954-32588-9-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Mon, 10 May 2010 11:39:14 -0400

> From: Sonic Zhang <sonic.zhang@analog.com>
> 
> If the platform data for the mii_bus is missing, gracefully error out
> rather than deference NULL pointers.
> 
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

Applied.
