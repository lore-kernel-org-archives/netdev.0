From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: bcm43xx-softmac maintainer
Date: Tue, 15 Aug 2006 18:33:50 -0500
Message-ID: <44E259DE.50806@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:32504 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1750815AbWHOXea (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 19:34:30 -0400
To: John Linville <linville@tuxdriver.com>,
	Bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As of today, I have taken on the duties of maintaining the bcm43xx-softmac code. 
I thank Michael Buesch for the heroic job that he has done. He ruffled a few 
feathers ;-) now and then, but he probably exhibited more patience than many 
would have. Michael will be concentrating on the bcm43xx-dscape (AKA d80211) 
code. It is expected that the many extra features of d80211 will eventually lead 
to its acceptance as the "official" 802.11 stack of Linux, replacing 
bcm43xx-softmac, which will probably die at that point. In the meantime, I'm 
here to keep as good a product as possible for the users of mainline kernels. 
Nearly everyone agrees that wireless networking is one area where Linux is 
deficient; however, the situation has improved so much in the past year that I 
have great hopes that it will soon be as easy to configure Wi-Fi in Linux as it 
is in XP or Vista. I know that it will be more secure!

Please send bug reports to me, with proposed fixes if available. Please include 
any past reports that you think might have been lost. I admit that I didn't read 
all the pertinent E-mails as studiously as I will now.

I am particularly interested in the "MAC suspend failure" messages as my own 
interface is one that suffers from this problem. If you see this message, please 
send me the chip ID line from your logs, which will look something like 
"bcm43xx: Chip ID 0x4306, rev 0x2".

Thanks,

Larry
