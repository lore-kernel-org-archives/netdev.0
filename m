From: Stephen Clark <sclark46@earthlink.net>
Subject: Linux vs FreeBSD Which is correct.
Date: Wed, 17 Aug 2011 13:03:18 -0400
Message-ID: <4E4BF456.9000807@earthlink.net>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-junco.atl.sa.earthlink.net ([209.86.89.63]:40945 "EHLO
	elasmtp-junco.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753624Ab1HQRDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2011 13:03:20 -0400
Received: from [69.22.83.66] (helo=joker.seclark.com)
	by elasmtp-junco.atl.sa.earthlink.net with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.67)
	(envelope-from <sclark46@earthlink.net>)
	id 1QtjWR-0002HI-PD
	for netdev@vger.kernel.org; Wed, 17 Aug 2011 13:03:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello List,

Firstly thank you for your patience.  I am replacing a bunch of FreeBSD 
vpn/fw/routers
with a Linux based system.

I have run into a situation where if I ping our HQ the response comes 
back on a different
interface than what the request went out on. FreeBSD is happy and says 
it got the response,
Linux is not and gives no indication it got a response.

So is FreeBSD wrong or is Linux wrong?

Or is there some sysctl I can fiddle with on Linux to make it see the 
response. This happens
with the iptables set to accept on all chains.

Thanks again for your indulgence. I googled this and didn't find 
anything germane.

-- 

"They that give up essential liberty to obtain temporary safety,
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty
decreases."  (Thomas Jefferson)



