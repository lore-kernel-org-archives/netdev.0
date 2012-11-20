From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] ipip: allow to deactivate the creation of
 fb dev
Date: Mon, 19 Nov 2012 19:07:53 -0500 (EST)
Message-ID: <20121119.190753.856116050444408241.davem@davemloft.net>
References: <1353082456-21234-2-git-send-email-nicolas.dichtel@6wind.com>
	<20121116082926.1c6cccd2@nehalam.linuxnetplumber.net>
	<50A66DD3.20807@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34788 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752541Ab2KTAHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 19:07:54 -0500
In-Reply-To: <50A66DD3.20807@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 16 Nov 2012 17:46:11 +0100

> By default, the fb device is created, so there is no change if you
> don't set explicitly setup_fb to 0.


Nicolas, this idea is contentous to me too.

Why not put this aside and submit the other parts of your
patch set on their own, since those looked fine to me?

Thanks.
