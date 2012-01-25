From: Stephen Clark <sclark46@earthlink.net>
Subject: NAT question
Date: Wed, 25 Jan 2012 10:54:37 -0500
Message-ID: <4F2025BD.20903@earthlink.net>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:52576 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754749Ab2AYQBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 11:01:07 -0500
Received: from [69.22.83.66] (helo=joker.seclark.com)
	by elasmtp-mealy.atl.sa.earthlink.net with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.67)
	(envelope-from <sclark46@earthlink.net>)
	id 1Rq5BG-0001Zb-2N
	for netdev@vger.kernel.org; Wed, 25 Jan 2012 10:54:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Can iptables do a network to network nat without having to write out a 
bunch of nat rules.
In other words translate  192.168.198.0/24 to 172.16.10.0/24 without 
having to write out
256 rules.

Also can iptables handle 1000 nat rules like above if they have to be 
written out on
a 1.66ghz intel dual core atom with 1gb of mem.

I know this isn't appropriate question for devel list but I didn't find 
anything googling.

Thanks,

-- 

"They that give up essential liberty to obtain temporary safety,
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty
decreases."  (Thomas Jefferson)
