From: kernel-dev@ballcam.com
Subject: [BOUNTY] Need a Working Driver Brought Up From 2.6.29 to 2.6.34.
 Will Pay.
Date: Sun, 09 Jun 2013 15:41:21 -0500
Message-ID: <20130609204121.28418.qmail@ballcam.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ballcam.com ([184.173.145.60]:50840 "HELO ballcam.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750727Ab3FIUsE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jun 2013 16:48:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have an OEM Driver that works Excellent under 2.6.29.

I need it working in 2.6.34

The Target Platform is ARM / Gumstix Overo. -- Wi2Wi / Marvell W2CBW003

The stack trace from when the module hangs on load 
gives switch_to() as the last function call when addr2line
is used to check the address against the kernel file.

Also, the driver does not curently use the net_driver_ops
API.

I have signed the NDA with the OEM, and I think the SRC 
is OK for GPL.

After this issue is solved the project will go on IndieGoGo,
and I will take it to the next level. For now I can pay,
but I am not a MegaCorp.   

I can certainly work with anyone offline, but please
respond here if appropriate. 

I do believe the end product can, and probably should
be included in the 2.6.34 mainline release.

Thanks,
BallCam.
