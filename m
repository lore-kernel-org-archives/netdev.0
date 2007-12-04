From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'upstream-jgarzik' branch of wireless-2.6
Date: Tue, 04 Dec 2007 15:13:19 -0500
Message-ID: <4755B4DF.10803@garzik.org>
References: <20071204135925.GB19911@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51513 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752146AbXLDUNW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 15:13:22 -0500
In-Reply-To: <20071204135925.GB19911@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John W. Linville wrote:
> Jeff,
> 
> Here are more than 5 score patches intended for 2.6.25.  This request
> replaces the request sent on 27 November. [1]
> 
> There are tons of updates here, especially iwlwifi and libertas.  The
> b43, b43legacy, rt2x00, rtl8187, and zd1211rw drivers are also updated.
> 
> This pull contains the port of zd1211rw to the mac80211 infrastructure.
> There is also some SSB stuff in there.  I've been sending that stuff
> to Dave M., but since later b43 patches depend on it I thought it
> would be better to send them your way.  I'll CC Dave.
> 
> Also included is the iwl4965 work to use the .11n stuff that has been
> added in the net-2.6.25 tree.  For now I've added a "depends on n" to
> the IWL4965_HT Kconfig to avoid build breakage in your tree.
> 
> The total diff is getting big -- the patch is nearing 2MB.  Please let
> me know if there are any problems so we can get (at least some of)
> this merged!
> 
> Thanks,
> 
> John
> 
> [1] http://marc.info/?l=linux-netdev&m=119617493212177&w=2
> 
> ---
> 
> Individual patches are available here:
> 
> 	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/upstream-jgarzik
> 
> ---
> 
> The following changes since commit e86d91426d8b3d79010c9d5c617d7594e5c165aa:
>   Jeff Garzik (1):
>         Merge branch 'r6040' of git://git.kernel.org/.../romieu/netdev-2.6 into upstream
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-jgarzik

pulled


