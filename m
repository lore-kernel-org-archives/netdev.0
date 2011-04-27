From: Ajit <ajitsa_bes@yahoo.com>
Subject: Maximum no of bytes Ethernet can transfer at a time ??
Date: Wed, 27 Apr 2011 12:11:35 +0000 (UTC)
Message-ID: <loom.20110427T140651-957@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:34910 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755354Ab1D0MPI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2011 08:15:08 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1QF3e4-0000Jf-ST
	for netdev@vger.kernel.org; Wed, 27 Apr 2011 14:15:07 +0200
Received: from mumbai-123-5.primenet.in ([203.115.123.5])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 14:15:04 +0200
Received: from ajitsa_bes by mumbai-123-5.primenet.in with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 14:15:04 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Guys,

I have developed a code which uses raw sockets to transfer files. My code skips
all the upper layer protocols,I have designed a small protocol of my own.

Now to problem is, whenever I transfer a large file it creates a problem. If
transfer a file of suppose 100kb or more, only 97.9 Kb is received, unlike in
the case of files smaller that 97.9.

What can be the problem ?? Does continuously sending and receiving of frames
creates a problem ??

If any one is interested I can give you my code..

Thank you. 

