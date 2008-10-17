From: Jerry McBride <mcbrides9@comcast.net>
Subject: B43 randomly and silently dropping connections...
Date: Fri, 17 Oct 2008 18:36:46 -0400
Message-ID: <200810171836.47059.mcbrides9@comcast.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:50479
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753444AbYJQWmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 18:42:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The story is...

I've moved from 2.6.25.x using BCM43XX with a Broadcom 4306 (rev3) 802.11 
chipset to 2.6.26.6 using the B43 and appropriate firmware. This on a COMPAQ 
Presario R3000 P4 and  a gig of memory and ATI graphics.

I followed the install (upgrade) directions at linuxwireless.org. Piece of 
cake! However... I find that I've gone from "bulletproof" BCM43XX wifi 
connections to "bullethole" connections with B43.  

Under the old BCM43XX the handshake and connections were flawless and 
unfaltering. Now with the new B43, handshakes with AP's are perfect, but the 
connections randomly and silently fail. There are no debug messages, no 
complaints what-so-ever in /var/log/messages... 

To gt wireless back, I have to reinitialize the connection. I've gotten so 
good at it, that I can recite by heart the appropriate commands...

It's killling me! I've got to get this ironed out... it's not just my laptop, 
it's happening quite regularly with people I know with similar chips and 
laptops.

Trying 2.6.27-rc's and now 2.6.27 and the situation is no better.

So I ask... Who is the B43/B43LEGACY maintainer and would you be interested in 
debugging this mess? I'll bend over backward to help you... Email me 
direct... I'm very willing.

SHORT STORY:
-- Kernel 2.6.25.x with BCM43XX, firmware 4.80.53.0.. just perfect.

-- Kernels 2.6.26 or higher with B43 and firware 4.150.10.5 good negotiations, 
but fragile connections that drop randomly and without complaint. B43LEGACY 
does nothing.

Any help would be appreciated. I'd really like to get this ironed out. I 
highly desire to use current kernels.

Feel free to email me direct.

-- 

*****************************************************************************
                                       
                             From the desk of:
                             Jerome D. McBride
                                       
   19:17:28 up 15 days, 23:35,  5 users,  load average: 0.33, 0.11, 0.03
 
*****************************************************************************
