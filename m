From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch 08/10] bcm43xx: sysfs code cleanup
Date: Thu, 20 Apr 2006 00:17:57 +0200
Message-ID: <20060419221757.GA29110@electric-eye.fr.zoreil.com>
References: <200604190405.k3J457Zj008004@shell0.pdx.osdl.net> <20060419215035.GA29122@electric-eye.fr.zoreil.com> <200604200005.01087.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, linville@tuxdriver.com, netdev@vger.kernel.org,
	greg@kroah.com, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:6052 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751283AbWDSWXI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Apr 2006 18:23:08 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200604200005.01087.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch <mb@bu3sch.de> :
[...]
> the deleted code parses binary input. The
> new code parses human readable hex input.

No offence intended but it was not clear from the description of
the patch.

<pavlov>
Does it imply an user space visible API change ?
</pavlov>

-- 
Ueimor
