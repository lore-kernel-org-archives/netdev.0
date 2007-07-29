From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Sun, 29 Jul 2007 22:53:12 +0200
Message-ID: <874pjn3paf.fsf@p4.be.48ers.dk>
References: <11846120522745-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>,
	Bahadir Balban <Bahadir.Balban@arm.com>,
	Dustin Mcintire <dustin@sensoria.com>,
	Bill Gatliff <bgat@billgatliff.com>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp40.mobistarmail.be ([193.252.23.61]:62237 "EHLO
	smtp40.mobistarmail.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752719AbXG2UwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 16:52:19 -0400
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf4017.mobistarmail.be (SMTP Server) with ESMTP id 504CB7000099
	for <netdev@vger.kernel.org>; Sun, 29 Jul 2007 22:52:17 +0200 (CEST)
In-Reply-To: <11846120522745-git-send-email-steve.glendinning@smsc.com> (Steve
	Glendinning's message of "Mon, 16 Jul 2007 19:54:12 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "Steve" == Steve Glendinning <steve.glendinning@smsc.com> writes:

Hi,

 Steve> Attached is a driver for SMSC's LAN911x and LAN921x families
 Steve> of embedded ethernet controllers.

 Steve> There is an existing smc911x driver in the tree; this is intended to
 Steve> replace it.  Dustin McIntire (the author of the smc911x driver) has
 Steve> expressed his support for switching to this driver.

What's the problem with Dustin's driver? It seems to work fine here
with a lan9117. Why not just add lan921x support to the existing
driver?

-- 
Bye, Peter Korsgaard

