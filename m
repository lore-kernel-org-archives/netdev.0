From: Jeff Garzik <jeff@garzik.org>
Subject: New tulip maintainer...
Date: Thu, 08 Jun 2006 11:41:28 -0400
Message-ID: <44884528.2040804@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:16847 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964891AbWFHPlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 11:41:31 -0400
To: Val Henson <val.henson@gmail.com>,
	Grant Grundler <grundler@parisc-linux.org>,
	Andrew Morton <akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that we have a new tulip maintainer, perhaps a resend of the 
long-outstanding tulip phy patches could be resent?

With an active tulip maintainer, the "too-long mdelay" would hopefully 
only exist temporarily -- with the proper fix being to move that code 
into a kernel thread (workqueue?) long term.

	Jeff


