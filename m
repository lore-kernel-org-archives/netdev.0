From: Stephen Clark <sclark46@earthlink.net>
Subject: route cache flush??
Date: Fri, 03 Feb 2012 09:59:10 -0500
Message-ID: <4F2BF63E.1@earthlink.net>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:60524 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756164Ab2BCO7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 09:59:11 -0500
Received: from [69.22.83.66] (helo=joker.seclark.com)
	by elasmtp-mealy.atl.sa.earthlink.net with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.67)
	(envelope-from <sclark46@earthlink.net>)
	id 1RtKbW-0005wz-Ui
	for netdev@vger.kernel.org; Fri, 03 Feb 2012 09:59:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have been beating my head against the wall for 2 days trying to
figure why when I change a route and do a "ip route flush cache"
it still takes up to a minute for packets to start using the new
route.

Is there a step I am missing?

kernel is 2.6.32

-- 

"They that give up essential liberty to obtain temporary safety,
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty
decreases."  (Thomas Jefferson)
