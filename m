From: Nik Trevallyn-Jones <nik777@users.sf.net>
Subject: Submitting new device driver
Date: Fri, 04 Feb 2011 14:05:14 +1100
Message-ID: <4D4B6CEA.5060900@users.sf.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from babel.homelinux.net ([61.29.36.94]:41499 "EHLO mail.internal"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752925Ab1BDDhe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Feb 2011 22:37:34 -0500
Received: from hplaptop.babel.homelinux.net (unknown [192.168.0.20])
	by mail.internal (Postfix) with ESMTP id CB06CD226C
	for <netdev@vger.kernel.org>; Fri,  4 Feb 2011 14:06:43 +1100 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear network kernel maintainers,

I maintain a device driver for a family of wireless broadband devices 
for the iBurst (TM) system.

I am being asked by the community when (or possibly if) the driver will 
be incorporated into the mainline kernel so users no longer need to 
download and build the driver themselves.

To that end, I've been reading the various documents on requirements for 
submitting a driver, and am now trying to contact the appropriate 
maintainers.

The drivers include support for PCMCIA and USB hardware, and are 
currently available from here:

http://sourceforge.net/projects/ibdriver/

I have recently made changes to support the 2.6.36 kernel, and will 
shortly review all the code to ensure compliance with the various 
guidelines regarding mainline drivers.

Could you please either let me know who I should direct my 
request/submission to, or point me to the appropriate document that 
tells me?

Many thanks for any and all responses,

Cheers!
Nik
