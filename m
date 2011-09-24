From: Stephen Clark <sclark46@earthlink.net>
Subject: Bridging broken/unfriendly
Date: Sat, 24 Sep 2011 18:28:06 -0400
Message-ID: <4E7E5976.1070200@earthlink.net>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:56040 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752591Ab1IXWfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2011 18:35:08 -0400
Received: from [69.22.83.66] (helo=joker.seclark.com)
	by elasmtp-banded.atl.sa.earthlink.net with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.67)
	(envelope-from <sclark46@earthlink.net>)
	id 1R7ahb-0000nu-7e
	for netdev@vger.kernel.org; Sat, 24 Sep 2011 18:28:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Is there some reason Linux bridging won't let the ip address be on
one of the interfaces, like FreeBSD does, instead of the bridge device?

This makes it very difficult or impossible to remotely add the interface
you are remoted in on to a bridge, or is there some sneaky way to
do this without losing your connection?

Thanks,
Steve

-- 

"They that give up essential liberty to obtain temporary safety,
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty
decreases."  (Thomas Jefferson)
