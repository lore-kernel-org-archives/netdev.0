From: Stephen Clark <sclark46@earthlink.net>
Subject: ipsec encryption
Date: Sun, 19 Sep 2010 17:04:38 -0400
Message-ID: <4C967AE6.2020207@earthlink.net>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:43568
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754487Ab0ISVEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Sep 2010 17:04:40 -0400
Received: from [69.22.83.66] (helo=joker.seclark.com)
	by elasmtp-spurfowl.atl.sa.earthlink.net with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.67)
	(envelope-from <sclark46@earthlink.net>)
	id 1OxR3w-0004gt-5k
	for netdev@vger.kernel.org; Sun, 19 Sep 2010 17:04:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello List,

I have been searching for a diagram that shows where in the packet flow thru
the kernel that ipsec encryption/encapsulation takes place in relation 
to the
netfilter flow diagrams. None of the netfilter diagrams I have found 
indicate
where ipsec encryption/decryption takes place.

Thanks in advance,
Steve

-- 

"They that give up essential liberty to obtain temporary safety,
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty
decreases."  (Thomas Jefferson)



