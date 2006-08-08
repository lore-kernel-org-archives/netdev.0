From: Patrick McHardy <kaber@trash.net>
Subject: Re: Linux v2.6.18-rc4
Date: Tue, 08 Aug 2006 20:24:27 +0200
Message-ID: <44D8D6DB.6040007@trash.net>
References: <Pine.LNX.4.64.0608061127070.5167@g5.osdl.org> <Pine.LNX.4.61.0608081943470.18225@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:936 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S964976AbWHHSYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 14:24:31 -0400
To: Jan Engelhardt <jengelh@linux01.gwdg.de>
In-Reply-To: <Pine.LNX.4.61.0608081943470.18225@yvahk01.tjqt.qr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
>>It's been a week since -rc3, so now we have a -rc4.
> 
> 
> 2.6.18 comes with ipt_statistic, but there is no way from userspace 
> (iptables) to use it (libipt_statistic.so simply does not come with the 
> latest iptables from svn). Does someone know what's going on?

I still have to add the userspace part to SVN.
