From: <pcnet32@verizon.net>
Subject: Re: Re: Strange connection slowdown on pcnet32
Date: Fri, 16 Feb 2007 10:21:24 -0600 (CST)
Message-ID: <32943920.1119801171642884331.JavaMail.root@vms226.mailsrvcs.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms044pub.verizon.net ([206.46.252.44]:51678 "EHLO
	vms044pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945979AbXBPQXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Feb 2007 11:23:30 -0500
Received: from vms226.mailsrvcs.net ([192.168.1.1])
 by vms044.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0JDK00A0BDFOPG29@vms044.mailsrvcs.net> for
 netdev@vger.kernel.org; Fri, 16 Feb 2007 10:21:24 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Are there any messages in the log about timeouts, or anything else from the driver? When it gets in this state, can you communicate with another system, and does it have the same slow behavior?

Looks like my mailer is munging white spaces.

On Fri, Feb 16, 2007 at 09:35:54AM -0500, Lennart Sorensen wrote:
> I have run some tests using 2.6.8 now, and so far it hasn't failed.
> 
> Still investigating...

And 5 minutes later 2.6.8 failed the same way too.  Maybe I will go back
to 2.4 and check.

--
Len Sorensen
-
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

