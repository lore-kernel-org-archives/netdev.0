From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH - RFC] [1/5] 64-bit network statistics - generic net
Date: Sat, 05 Jul 2003 16:40:49 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F0737D1.5090109@pobox.com>
References: <E19YtAq-0006Xf-00@calista.inka.de> <200307051637.52252.jeffpc@optonline.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bernd Eckenfels <ecki@calista.eckenfels.6bone.ka-ip.net.sgi.com>,
   linux-kernel@vger.kernel.org, Andrew Morton <akpm@digeo.com>,
   Dave Jones <davej@codemonkey.org.uk>, Linus Torvalds <torvalds@osdl.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Sipek <jeffpc@optonline.net>
In-Reply-To: <200307051637.52252.jeffpc@optonline.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The net stats are already unsigned long internally.

64-bit case is handled quite nicely today, thanks :)

I'm such a 64-bit bigot that "buy a 64-bit computer" is a solution I 
commonly suggest, and it seems to fit well here, too.

	Jeff, wondering if Intel will bother to compete w/ Athlon64
