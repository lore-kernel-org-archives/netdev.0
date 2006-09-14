From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] bcm43xx: fix netdev watchdog timeouts
Date: Thu, 14 Sep 2006 08:54:11 -0500
Message-ID: <45095F03.8020500@lwfinger.net>
References: <45095916.mailNQM11V1HV@lwfinger.net> <20060914133714.GF1845@harddisk-recovery.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stefano Brivio <st3@riseup.net>,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:1419 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1750779AbWINNyT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 09:54:19 -0400
To: Erik Mouw <erik@harddisk-recovery.com>
In-Reply-To: <20060914133714.GF1845@harddisk-recovery.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Erik Mouw wrote:
> On Thu, Sep 14, 2006 at 08:28:54AM -0500, Larry Finger wrote:
>> Please apply this to wireless-2.6. It would be great if this patch were to be
>> included in 2.6.19.
> 
> I suppose you mean 2.6.18?
> 
> It would also be nice if your "bcm43xx locks up machine" patch were to
> be included in 2.6.18 together with this patch or we will see
> regression reports against 2.6.17.

This section in wireless 2.6 already differed by quite a bit from that in 
2.6.18-rcX. As a result, John Linville thinks that applying this patch to 2.6.18 
would lead to messiness in the git trees and has recommended that I hold the 
patch until it can be sent to the stable maintainers for inclusion in 2.6.18.y. 
Yes there will be a regression against 2.6.17.

Larry
