From: Michael Durket <durket@highwire.stanford.edu>
Subject: Question about tg3 and bnx2 driver suppliers
Date: Thu, 17 Feb 2011 05:24:13 -0800
Message-ID: <3BA51C2C-B28F-4FED-BF5D-B9BF46EAF3F7@highwire.stanford.edu>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from highwire.Stanford.EDU ([171.66.121.166]:65046 "EHLO
	highwire.stanford.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756518Ab1BQNvI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 08:51:08 -0500
Received: from [192.168.45.74] (eniac.stanford.edu [171.66.122.117])
	by highwire.stanford.edu (Postfix) with ESMTP id D438A8D45
	for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 05:24:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm trying to fix a problem with packet drops and frame errors (really rxbds_empty and rx_discards (or rx_fw_discards depending on whether or not its a tg3 supported chip or a bnx2 chip)). We have this happening on pretty much all the RedHat 5.x systems we're running these drivers on. In investigating what remedies to employ to fix this, I'm trying to determine if new versions of this driver are supplied by Broadcom, or by people within the Linux community so 
I can find the right place to ask questions about it. I'm pretty sure this isn't the right list for these types of questions, but if someone could tell me whether I should be contacting Broadcom directly, or the name of some other Linux mailing list or forum that might help, I'd appreciate it.

