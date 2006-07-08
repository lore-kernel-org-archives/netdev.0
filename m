From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] tg3: add amd8131 to "write reorder" chipsets
Date: Fri, 7 Jul 2006 17:49:06 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC093F9B3@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:6663 "EHLO MMS3.broadcom.com")
	by vger.kernel.org with ESMTP id S932468AbWGHAtV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 20:49:21 -0400
Content-class: urn:content-classes:message
To: "David Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> I think that since we do have a proof positive report, and well
> documented success of the fix, we should add the fix even though
> we have the fallback thing to take care of it.
> 
> This is how we were going to use the fall-back code, to make the the
> chipset blacklist more robust yet still allow the user's machine to
> work meanwhile.  Here, we have enough information to add the blacklist
> entry safely.
> 
> What do you think?
> 
> 
OK, no objection to merging it now.

