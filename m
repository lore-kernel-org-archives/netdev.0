From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] bcm43xx-d80211: Init, shutdown and restart fixes
Date: Tue, 15 Aug 2006 10:23:18 -0500
Message-ID: <44E1E6E6.9000804@lwfinger.net>
References: <200608142132.25398.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Johannes Berg <johannes@sipsolutions.net>,
	bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:42137 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1030291AbWHOPXb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 11:23:31 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200608142132.25398.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael,

Michael Buesch wrote:
> Hi John,
> 
> Please apply this to wireless-dev.
> 
> --
> 
> This fixes various bugs in the init and shutdown code
> that would lead to lockups and crashes.
> This is best reproducable by receiving a timeout from
> the netdev watchdog.

Is a similar bug likely to be the cause of the netdev watchdog timeouts in 
bcm43xx-softmac? If so, will there be a patch for wireless-2.6?

Thanks,

Larry

